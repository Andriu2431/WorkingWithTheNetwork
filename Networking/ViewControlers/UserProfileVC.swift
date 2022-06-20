
import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn

//Вихід з акаунта

class UserProfileVC: UIViewController {

    private var provider: String?
    private var currentUser: CurrentUser?

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //Кнопка для виходу з акаунта
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32, y: view.frame.height - 172, width: view.frame.width - 64, height: 50)
        button.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
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
        view.addSubview(logoutButton)
    }

}

//MARK: Facebook and Google SDK

extension UserProfileVC {

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
                    self.currentUser = CurrentUser(uid: uid, data: userData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = self.getProviderData()

                } withCancel: { error in
                    print(error)
                }
        }
    }

    //Метод для тапу по кнопці виходу
    @objc private func signOut() {

        //Перевіримо через що користувач зарейстравався
        if let providerData = Auth.auth().currentUser?.providerData {

            //Переберемо масив з айді юзера
            for userInfo in providerData {

                switch userInfo.providerID {
                case "facebook.com":
                    //Виходимо з facebook
                    LoginManager().logOut()
                    print("User did log out of facebook")
                    openLoginViewController()
                case "google.com":
                    //Виходимо з google
                    GIDSignIn.sharedInstance.signOut()
                    print("User did log out of google")
                    openLoginViewController()
                default:
                    print("User is signed in with \(userInfo.providerID)")
                }
            }
        }
    }

    //Метод буде оприділяти провайдера та вертати текст в залежності від цього провайдера
    private func getProviderData() -> String {
        var greetings = ""

        if let providerData = Auth.auth().currentUser?.providerData {

            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebbok"
                case "google.com":
                    provider = "Google"
                default:
                    break
                }
            }

            greetings = "\(currentUser?.name ?? "Noname") \(currentUser?.email ?? "Noemail") Logged in with \(provider ?? "Noprovider")"
        }

        return greetings
    }
}
