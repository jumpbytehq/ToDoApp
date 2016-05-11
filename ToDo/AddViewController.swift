

import UIKit
import CoreData

class AddViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBAction func savePressed(sender: AnyObject) {
        if textBox.text != ""{
            
            let timeFormatter = NSDateFormatter()
            timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let time = timeFormatter.stringFromDate(timePicker.date)
            
            let timeInvert = time.componentsSeparatedByString(" ")
            
            let hour = timeInvert[0].componentsSeparatedByString(":")
            
            var saveTime = ""
            
            if Int(hour[0]) < 10{
                saveTime = "\(timeInvert[1]) 0\(timeInvert[0])"
            }
            else{
                saveTime = "\(timeInvert[1]) \(timeInvert[0])"
            }
            
            
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            let entity =  NSEntityDescription.entityForName("Tasks", inManagedObjectContext:managedContext)
            
            let task = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            task.setValue(textBox.text, forKey: "task")
            task.setValue(saveTime, forKey: "time")
            
            do {
                try managedContext.save()
                
                leftTasks.append(task)
            }
            catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            
            let notification = UILocalNotification()
            notification.alertBody = "\(textBox.text!)" // text that will be displayed in the notification
            notification.fireDate = timePicker.date // todo item due date (when notification will be fired)
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["UUID": textBox.text!, ] // assign a unique identifier to the notification so that we can retrieve it later
            notification.category = "TODO_CATEGORY"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
            performSegueWithIdentifier("addTask", sender: self)
            
        }
        
        else{
            let alertController = UIAlertController(title: "Empty Field", message: "Task cannot be left empty!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    @IBOutlet weak var textBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textBox.backgroundColor = UIColor.grayColor()
        timePicker.setValue(UIColor.whiteColor(), forKeyPath: "textColor")
        timePicker.datePickerMode = .Time
        textBox.delegate = self
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(userBox: UITextField) -> Bool {
        userBox.resignFirstResponder()
        return true;
    }
    
}
