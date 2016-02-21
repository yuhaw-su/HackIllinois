//
//  CameraViewController.swift
//  JohnCenify
//
//  Created by Richard Su on 2/20/16.
//  Copyright © 2016 Richard Su. All rights reserved.
//

import UIKit
import Alamofire
import AVKit
import AVFoundation

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var faceButton: UIButton!
	@IBOutlet weak var directionsLabel: UILabel!
	@IBOutlet weak var angerLevelLabel: UILabel!
	
	let imagePicker: UIImagePickerController! = UIImagePickerController()
	var angerIndex: Float = 0.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		titleLabel.hidden = false
		faceButton.hidden = false
		directionsLabel.hidden = false
		angerLevelLabel.hidden = true
	}
	
	func getEmotions(url: String)
	{
		let manager = Alamofire.Manager.sharedInstance
		let headers = ["Content-Type": "application/json",
			"Ocp-Apim-Subscription-Key": "f0f69f4aa6634d38986f3f5b1308778f"]
		
		manager.request(.POST, "https://api.projectoxford.ai/emotion/v1.0/recognize",
			parameters: ["url": url],
			headers: headers,
			encoding: .JSON)
			.responseJSON { response in
				print(response.request!)  // original URL request
				print(response.response!) // URL response
				print(response.data!)     // server data
				print(response.result)    // result of response serialization

				if let JSON = response.result.value
				{
					print("JSON: \(JSON)")
					if JSON.count! > 0
					{
						self.angerIndex = JSON[0]!["scores"]!!["anger"] as! Float
					}
					else
					{
						self.angerIndex = 0.0
					}
					print(self.angerIndex)
					self.checkAngerIndex()
				}
			}
	}
	
	func checkAngerIndex()
	{
		angerLevelLabel.text = "Anger Level: \(round(100.0 * angerIndex)/10.0)/10"
		if angerIndex > 0.5
		{
			titleLabel.text = "HELLO ..."
			directionsLabel.text = "AND GOODBYE to ANYONE standing in JOHN CENA's WAY!"
			do {
                try playVideo()
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
		}
		else
		{
			titleLabel.text = "MORE ANGER"
			directionsLabel.text = "You'll need to be even MADDER to get to the WWE SUPERSLAM!"
		}
		titleLabel.hidden = false
		faceButton.hidden = false
		angerLevelLabel.hidden = false
	}
	
	@IBAction func takePicture(sender: UIButton)
	{
		if (UIImagePickerController.isSourceTypeAvailable(.Camera))
		{
			if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
			{
				imagePicker.delegate = self
				imagePicker.allowsEditing = false
				imagePicker.sourceType = .Camera
				imagePicker.cameraCaptureMode = .Photo
				presentViewController(imagePicker, animated: true, completion: {})
			}
			else
			{
				print("Rear camera doesn't exist: Application cannot access the camera.")
			}
		} else
		{
			print("Camera inaccessable: Application cannot access the camera.")
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
	{
		self.titleLabel.hidden = true
		self.faceButton.hidden = true
		self.angerLevelLabel.hidden = true
		self.directionsLabel.text = "Measuring anger ..."
		print("Got an image")
		if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage
		{
			let pickedImageData:NSData = NSData(data: UIImageJPEGRepresentation(pickedImage, 1.0)!)
			let pickedImageB64 = pickedImageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
			let manager = Alamofire.Manager.sharedInstance
			let parameters = ["image": pickedImageB64]
			let headers = ["Authorization": "Client-ID 2042268fa3a0f19"]
			manager.request(.POST, "https://api.imgur.com/3/image",
				parameters: parameters,
				headers: headers,
				encoding: .URL)
				.responseJSON { response in
					print(response.request!)  // original URL request
					print(response.response!) // URL response
					print(response.data!)     // server data
					print(response.result)    // result of response serialization

					if let JSON = response.result.value
					{
						print("JSON: \(JSON)")
						let JSONdata = JSON["data"]!
						self.getEmotions(JSONdata!["link"]! as! String)
					}
				}
		}
		imagePicker.dismissViewControllerAnimated(true, completion: {})
	}
 
	func imagePickerControllerDidCancel(picker: UIImagePickerController)
	{
		print("User canceled image")
		titleLabel.text = "John Cenify"
		directionsLabel.text = "Tap on Cena and make an angry face!"
		angerLevelLabel.hidden = true
		dismissViewControllerAnimated(true, completion:
		{
		})
	}
	
	private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("john_cena_meme", ofType:"m4v") else {
            throw AppError.InvalidResource("john_cena_meme", "m4v")
        }
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()            
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }

}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}
