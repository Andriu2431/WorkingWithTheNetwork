
import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

//Вихід з акаунта

class UserProfileVC: UIViewController {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Кнопка для виходу з акаунта
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: view.frame.height - 172, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        userNameLabel.isHidden = true
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fethingUserData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
    }

}

//MARK: Facebook SDK

extension UserProfileVC: LoginButtonDelegate {

    //Відслідковує авторизацію користувача
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {

        if error != nil {
            print(error!)
            return
        }

        print("Successfully logged in with facebook...")
    }

    //Відслідковує вихід з акаунта
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

        print("Did log out with facebook")

        openLoginViewController()
    }

    private func openLoginViewController() {

        //Видалимо зарейстрованого користувача з firebase
        do {
            //Видаляємо його
            try Auth.auth().signOut()

            //Відкриваємо екран рейстрації
            DispatchQueue.main.async {
                //Екземпляр сторіборда
                let storyBord = UIStoryboard(name: "Main", bundle: nil)
                //Контролер по ідентифікатору
                let logitVC = storyBord.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController

                self.present(logitVC, animated: true)
                return
            }

        } catch let error {
            print("Failed to sign out with error", error.localizedDescription)
        }
    }

    //Метод для загрузки данних з firebase
    private func fethingUserData() {
        
        //Перевіримо чи користувач зарейстрований
        if Auth.auth().currentUser != nil {
            
            //Получаємо ідентифікатор користувача
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            //Звертаємось до бази данних. snapshot - знімок бази данних, тобто дані по тому ключу
            Database.database().reference()
                .child("users")
                .child(uid)
                .observeSingleEvent(of: .value) { snapshot in
                    
                    //Словник з данними
                    guard let userData = snapshot.value as? [String: Any] else { return }
                    //Розпарсимо цей словник через структуру(модель)
                    let currentUser = CurrentUser(uid: uid, data: userData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = "\(currentUser?.name ?? "Noname") \(currentUser?.email ?? "Nonemail") Logged in with Facebook"
                    
                } withCancel: { error in
                    print(error)
                }

        }
    }
}

