
import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

//Рейстрація користувача

class LoginViewController: UIViewController {
    
    //Екземпляр структури, яка тримає данні користувача з фестбукуʼ
    var userProfile: UserProfile?
    
    //Кнопка для рейстрації
    lazy var fbLoginButton: UIButton = {
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 360, width: view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    
    //Кастомна кнопка для SDK Facebook
    lazy var customFbLoginButton: UIButton = {
        let loginButton = UIButton()
        loginButton.backgroundColor = UIColor(hexValue: "#3B5999", alpha: 1)
        loginButton.setTitle("Login with Facebook", for: .normal)
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.frame = CGRect(x: 32, y: 360 + 80, width: view.frame.width - 64, height: 50)
        loginButton.layer.cornerRadius = 4
        loginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Задаємо колір view
        view.addVerticalGradientLayer(topColor: primaryColor, bottomColor: secondaryColor)
        
        setupViews()
        
    }
    
    private func setupViews() {
        view.addSubview(fbLoginButton)
        view.addSubview(customFbLoginButton)
    }

}

//MARK: Facebook SDK

extension LoginViewController: LoginButtonDelegate {

    //Відслідковує авторизацію користувача
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {

        if error != nil {
            print(error!)
            return
        }

        //Перевіримо токін, якщо він буде, то закриваємо екран рейстрації
        guard AccessToken.current != nil else { return }

        print("Successfully logged in with facebook...")
        
        singInfofirebase()
    }

    //Відслідковує вихід з акаунта
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {

        print("Did log out with facebook")
    }

    //Закриває контроллер рейстрації
    private func openMainViewController() {
        dismiss(animated: true)
    }

    
    //Метод при тапі на кастомну кнопку, також тут будемо працювати з firebase
    @objc private func handleCustomFBLogin() {

        LoginManager().logIn(permissions: ["email", "public_profile"], from: self) { result, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }

            guard let result = result else { return }

            //Якщо користувач не підтрерджує рейстрацію через фесбук, виходимо з метода
            if result.isCancelled { return }
            //Якщо користувач підтрерджує рейстрацію через фесбук
            else {
                self.singInfofirebase()
            }
        }
    }

    //Настройка firebase
    private func singInfofirebase() {

        //Беремо токен користувача
        let accessToken = AccessToken.current

        //Конвертуємо його в строку
        guard let accessTokenString = accessToken?.tokenString else { return }

        //Передаємо рейстрацію користувача firebase
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)

        //Авторизуємо користувача в firebase через facebook
        Auth.auth().signIn(with: credentials) { user, error in

            if let error = error {
                print("Error facebook user:", error)
                return
            }

            print("User Register:")
            //Получаємо дані про користувача
            self.fetchFecebookFields()
        }
    }
    
    //Тут получемо публічні дані про користувача який зарестрований
    private func fetchFecebookFields() {

        //Дані про користувача тримає в собі клас GraphRequest - graphPath так пише документація, а parameters, це поля кі ми хочемо отримати
        GraphRequest(graphPath: "me", parameters: ["fields" : "id, name, email"]).start { _, result, error in
            //result - прийде те, що запитували

            if let error = error {
                print(error)
                return
            }

            //Парсимо данні які прийли до dictionary
            if let userData = result as? [String: Any] {
                self.userProfile = UserProfile(data: userData)
                print(userData)
                self.saveInfoFirebase()
            }
        }
    }
    
    //Зберігаємо наші дані в firebase
    private func saveInfoFirebase() {
        
        //Це id юзера
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        //Словник з данними
        let userData = ["name": userProfile?.name, "email": userProfile?.email]
        
        //Цей словник будемо передавати в firebase, тобто по userId будемо передавати якісь дані
        let values = [uid: userData]
        
        //Створюємо нову дерикторію в базі данних, та добавляємо в неї данні
        Database.database().reference().child("users").onDisconnectUpdateChildValues(values) { error, _ in
            
            if let error = error {
                print(error)
                return
            }
            
            print("Seccessfully saved user firebase database")
            self.openMainViewController()
        }
    }
    
}
