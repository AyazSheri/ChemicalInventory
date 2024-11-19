import FirebaseCore
import FirebaseAuth
import FirebaseFirestore



class FirestoreService {
    private let db = Firestore.firestore()

    func createUserProfile(name: String, email: String, id: String, password: String, role: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    completion(false, "The email address is already in use. Please use a different email or log in.")
                } else {
                    completion(false, error.localizedDescription)
                }
                return
            }

            let userData: [String: Any] = [
                "name": name,
                "email": email,
                "id": id,
                "role": role
            ]

            self.db.collection("users").document(id).setData(userData) { error in
                if let error = error {
                    completion(false, error.localizedDescription)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // Add the loginUser function here
    func loginUser(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
}
