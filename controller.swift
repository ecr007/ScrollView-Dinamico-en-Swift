//
//  ViewController.swift
//  mbe
//
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
	
	@IBOutlet weak var btnChooseCountry: UIButton!
	
	@IBOutlet weak var email: UILabel!
	@IBOutlet weak var emailField: UITextField!
	
	@IBOutlet weak var restore: UIButton!
	
	@IBOutlet weak var objLoading: UIActivityIndicatorView!
	
	@IBOutlet weak var viewCountry: UIView!
	@IBOutlet weak var doneBtn: UIButton!
	@IBOutlet weak var pickerCountry: UIPickerView!
	@IBOutlet weak var objLoadingPicker: UIActivityIndicatorView!
	
	// Bussnes country
	var countrys = [Country]()
	var selectdCountry:String?
	
	var chooseCountry:String!
	
	// Business for scroll logic
	@IBOutlet weak var scroll: UIScrollView!
	@IBOutlet weak var mainView: UIView!
	
	// KeyBoard (For scroll)
	var activeField: UITextField?
	var lastOffset: CGPoint!
	var keyboardHeight: CGFloat!
	
	// Bottom of the last element (For scroll)
	@IBOutlet weak var bottomOfTheLastElement: NSLayoutConstraint!
	
	var mainViewHeight:CGFloat!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.btnChooseCountry.setBackgroundImage(UIImage(named: "arrow-black"), for: UIControl.State.normal)
		
		self.pickerCountry.dataSource = self
		self.pickerCountry.delegate = self
		
		self.emailField.delegate = self
		
		self.chooseCountry = NSLocalizedString("ecrselcountry",comment:"")
		
		// For dynamic scroll
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		// Add touch gesture for contentView
		self.mainView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
		
		// Set mainViewHeight
		self.mainViewHeight = self.mainView.frame.size.height
		
		// Ocultar teclado al tocar fuera del UITextField
		self.hideKeyboard()
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: LIMPIAR FORM
	func clearForm(){
		self.btnChooseCountry.setTitle(self.chooseCountry, for: .normal)
		self.emailField.text = nil
	}
	
	@IBAction func chooseCountry(_ sender: UIButton) {
		
		self.btnChooseCountry.isEnabled = false
		
		// Este metodo se encarga de ocultar el teclado
		self.view.endEditing(true)
		
		self.pickerCountry.isHidden = true
		self.objLoadingPicker.isHidden = false
		
		self.viewCountry.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
		self.viewCountry.isHidden = false
		
		UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
			
			let screenHeight = Helpers().screenHeight;
			let scrollHeight = self.scroll.frame.size.height
			
			var axisY:CGFloat = 0
			
			if screenHeight > (self.mainViewHeight+54){
				axisY = scrollHeight - self.mainViewHeight
				
				// Set height main view
				self.mainView.frame.size.height = self.mainViewHeight + axisY
			}
			
			self.viewCountry.transform = CGAffineTransform(translationX: 0, y: axisY)
			
			// Inicializamos el country
			self.countrys = []
			self.countrys.append(Country(iso: "NIL", name: self.chooseCountry))
			
			// Cargamos los paises
			if Helpers().checkInternet(){
				let ws = WebService()
				ws.getCountry { (res) in
					
					if res.count > 0{
						for data in res{
							
							let inf = JSON(data).dictionaryObject
							
							if let iso = inf!["iso2"] as? String, let name = inf!["name"] as? String{
								
								self.countrys.append(Country(iso: iso, name: name))
							}
						}
						
						self.objLoadingPicker.isHidden = true
						self.pickerCountry.reloadAllComponents()
						self.pickerCountry.isHidden = false
						self.btnChooseCountry.isEnabled = true
					}
					else{
						self.objLoadingPicker.isHidden = true
						self.hideCountry()
						self.present(Helpers().getAlert(titulo: nil, texto: NSLocalizedString("error_select_country",comment:"")), animated: true, completion: nil)
						self.btnChooseCountry.isEnabled = true
					}
				}
			}
			else{
				self.objLoadingPicker.isHidden = true
				self.hideCountry()
				self.present(Helpers().getAlert(titulo: nil, texto: NSLocalizedString("error_generar_1",comment:"")), animated: true, completion: nil)
				self.btnChooseCountry.isEnabled = true
			}
		}) {
			Void in
		}
	}
	
	@IBAction func restorePass(_ sender: UIButton) {
		
		self.hideCountry()
		
		self.objLoading.isHidden = false
		self.restore.isEnabled = false
		
		// Este metodo se encarga de ocultar el teclado
		self.view.endEditing(true)
		
		// Verificamos la conexion a la red
		if Helpers().checkInternet(){
			
			guard let email = emailField.text, !email.isEmpty else{
				self.restore.isEnabled = true
				self.objLoading.isHidden = true
				
				return self.present(Helpers().getAlert(titulo: NSLocalizedString("field_required",comment:""), texto: NSLocalizedString("error_email_required",comment:"")), animated: true, completion: nil)
			}
			
			guard let iso = self.selectdCountry else{
				self.restore.isEnabled = true
				self.objLoading.isHidden = true
				return self.present(Helpers().getAlert(titulo: NSLocalizedString("field_required",comment:""), texto: NSLocalizedString("error_select_country_required",comment:"")), animated: true, completion: nil)
			}
			
			let ws = WebService()
			ws.forgotPassword(email: email, iso: iso) { (res) in
				
				if res.count > 0{
					if let success = res["success"] as? String{
						
						let alert = UIAlertController(title: nil, message: success, preferredStyle: .alert)
						
						let ok = UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default, handler: { (accion) in
							self.clearForm()
							self.objLoading.isHidden = true
							self.restore.isEnabled = true
						})
						
						alert.addAction(ok)
						
						self.present(alert, animated: true, completion: nil)
					}
					else{
						self.present(Helpers().getAlert(titulo: nil, texto: NSLocalizedString("error_generar_1",comment:"")), animated: true, completion: nil)
						self.objLoading.isHidden = true
						self.restore.isEnabled = true
					}
				}
				else{
					self.present(Helpers().getAlert(titulo: nil, texto: NSLocalizedString("error_generar_1",comment:"")), animated: true, completion: nil)
					self.objLoading.isHidden = true
					self.restore.isEnabled = true
				}
			}
		}else{
			
			self.present(Helpers().getAlert(titulo: nil, texto: NSLocalizedString("error_generar_1",comment:"")), animated: true, completion: nil)
			self.objLoading.isHidden = true
			self.restore.isEnabled = true
		}
	}
	
	
	// MARK: hide country picker
	func hideCountry(){
		UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
			self.viewCountry.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
		}) {
			Void in
			self.viewCountry.isHidden = true
			self.mainView.frame.size.height = self.mainViewHeight
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return self.countrys.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return self.countrys[row].getName()
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		self.btnChooseCountry.setTitle(self.countrys[row].getName(), for: UIControl.State.normal)
		
		if self.countrys[row].getIso() == "NIL"{
			self.selectdCountry = nil
		}else{
			self.selectdCountry = self.countrys[row].getIso()
		}
	}
	
	// MARK: BOTON LISTO
	@IBAction func hideDonePicker(_ sender: UIButton) {
		self.hideCountry()
	}
}

// MARK: UITextFieldDelegate
extension RestorePassViewController: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		activeField = textField
		lastOffset = self.scroll.contentOffset
		
		self.hideCountry()
		
		return true
	}
	
	// MARK: Ocultar Teclado
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		activeField?.resignFirstResponder()
		activeField = nil
		
		textField.resignFirstResponder()
		return true
	}
}

// MARK: KEYBOARD EVENTS
extension RestorePassViewController {
	@objc func keyboardWillShow(notification: NSNotification) {
		if keyboardHeight != nil {
			return
		}
		
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			keyboardHeight = keyboardSize.height
			
			// so increase contentView's height by keyboard height
			UIView.animate(withDuration: 0.3, animations: {
				self.bottomOfTheLastElement.constant += self.keyboardHeight
			})
			
			if let actField = activeField{
				// move if keyboard hide input field
				let distanceToBottom = self.scroll.frame.size.height - (actField.frame.origin.y) - (actField.frame.size.height)
				let collapseSpace = keyboardHeight - distanceToBottom
				
				if collapseSpace < 0 {
					// no collapse
					return
				}
				
				// set new offset for scroll view
				UIView.animate(withDuration: 0.3, animations: {
					// scroll to the position above keyboard 10 points
					self.scroll.contentOffset = CGPoint(x: self.lastOffset.x, y: collapseSpace + 10)
				})
			}
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if let lastOffSet = self.lastOffset, let keyboardHeight = self.keyboardHeight{
			UIView.animate(withDuration: 0.3) {
				self.bottomOfTheLastElement.constant -= keyboardHeight
				
				self.scroll.contentOffset = lastOffSet
			}
		}
		
		keyboardHeight = nil
	}
	
	// MARK: OCULTAR TECLADO CON GESTO
	@objc func returnTextView(gesture: UIGestureRecognizer) {
		guard activeField != nil else {
			return
		}
		
		activeField?.resignFirstResponder()
		activeField = nil
	}
}
