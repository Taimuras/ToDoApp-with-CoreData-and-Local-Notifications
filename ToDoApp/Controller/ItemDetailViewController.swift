
import UIKit

protocol ItemDetailViewControllerDelegate: class {
    func addItemViewControllerDidCancel(_ controller: ItemDetailViewController)
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: Item)
}

class ItemDetailViewController: UIViewController {
    weak var delegate: ItemDetailViewControllerDelegate?
    weak var todoList: ToDoList?
    var itemToEdit: Item?
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        textField.delegate = self
        if let item = itemToEdit {
            titleLabel.text = item.title
            textField.text = item.titleDescription
            editButton.isEnabled = true
        }
        
    }
    
    
    @IBAction func editButtonTapped(_ sender: Any?) {
//        itemToEdit?.description = textField.text!
        if let item = itemToEdit, let text = textField.text {
            item.titleDescription = text
            delegate?.addItemViewController(self, didFinishEditing: item)
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any?) {
        print("Cancel Button Tapped")
        //dismiss(animated: true, completion: nil)
        delegate?.addItemViewControllerDidCancel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
    }
}


extension ItemDetailViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
              let stringRange = Range(range, in:oldText) else {
            return false
        }

        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
