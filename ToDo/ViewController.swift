

import UIKit
import CoreData


var doneTasks = [NSManagedObject]()

var leftTasks = [NSManagedObject]()

class ViewController: UIViewController {

    @IBOutlet weak var taskCount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var currentDate: UILabel!
    
    @IBOutlet weak var taskProgress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskProgress.transform = CGAffineTransformMakeScale(1, 3)
        
        tableView.backgroundColor = UIColor.clearColor()
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day , .Month], fromDate: date)
        
        currentDate.text = "\(components.day) \(getMonth(components.month))"
        
        
    }
    
    func getMonth(a: Int) -> String{
        switch a{
            case 1:
                return "January"
            case 2:
                return "February"
            case 3:
                return "March"
            case 4:
                return "April"
            case 5:
                return "May"
            case 6:
                return "June"
            case 7:
                return "July"
            case 8:
                return "August"
            case 9:
                return "September"
            case 10:
                return "October"
            case 11:
                return "November"
            case 12:
                return "December"
            default:
                return "xyz"
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Tasks")
        
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            leftTasks = results as! [NSManagedObject]
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let fetchRequest2 = NSFetchRequest(entityName: "DoneTasks")
        
        fetchRequest2.sortDescriptors = [sortDescriptor]
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest2)
            doneTasks = results as! [NSManagedObject]
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        taskCount.text = "\(leftTasks.count + doneTasks.count) open tasks"
        taskProgress.progress = Float(doneTasks.count) / (Float(doneTasks.count)+Float(leftTasks.count))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (leftTasks.count + doneTasks.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ToDoTableViewCell
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.doubleTapped(_:)))
        tap.numberOfTapsRequired = 2
        if indexPath.row < leftTasks.count{
            if leftTasks.count + doneTasks.count == 1{
                cell.line.image = UIImage(named: "redDot")
            }
            else if indexPath.row == 0{
                cell.line.image = UIImage(named: "redTop")
            }
            else if indexPath.row == (leftTasks.count + doneTasks.count - 1){
                cell.line.image = UIImage(named: "redBottom")
            }
            else{
                cell.line.image = UIImage(named: "red")
            }
            cell.task.text = leftTasks[indexPath.row].valueForKey("task") as? String
            cell.task.textColor = UIColor.grayColor()
            let time = leftTasks[indexPath.row].valueForKey("time") as? String
            let timeInvert = time!.componentsSeparatedByString(" ")
            cell.time.text = "\(timeInvert[1]) \(timeInvert[0])"
            cell.tick.image = nil
            cell.time.textColor = UIColor.grayColor()
            cell.check.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.clearColor()
            cell.check.addGestureRecognizer(tap)
        }
        else{
            if leftTasks.count + doneTasks.count == 1{
                cell.line.image = UIImage(named: "grayDot")
            }
            else if indexPath.row == 0{
                cell.line.image = UIImage(named: "grayTop")
            }
            else if indexPath.row == (leftTasks.count + doneTasks.count - 1){
                cell.line.image = UIImage(named: "grayBottom")
            }
            else{
                cell.line.image = UIImage(named: "gray")
            }
            cell.task.text = doneTasks[indexPath.row - leftTasks.count].valueForKey("task") as? String
            cell.task.textColor = UIColor.whiteColor()
            cell.time.text = "Done task"
            cell.time.textColor = UIColor.whiteColor()
            cell.check.layer.cornerRadius = 10
            cell.tick.image = UIImage(named: "checked")
            cell.check.addGestureRecognizer(tap)
            cell.backgroundColor = UIColor(red: 163.0/255.0, green: 163/255.0, blue: 163/255.0, alpha: 0.5)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            
            if indexPath.row < leftTasks.count{
                managedContext.deleteObject(leftTasks[indexPath.row])
                appDelegate.saveContext()
                for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
                    if (notification.userInfo!["UUID"] as! String == String(leftTasks[indexPath.row].valueForKey("task"))) {
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                        break
                    }
                }
                leftTasks.removeAtIndex(indexPath.row)
            }
            else{
                managedContext.deleteObject(doneTasks[indexPath.row - leftTasks.count])
                appDelegate.saveContext()
                doneTasks.removeAtIndex(indexPath.row - leftTasks.count)
            }
            taskProgress.progress = Float(doneTasks.count) / (Float(doneTasks.count)+Float(leftTasks.count))
            taskCount.text = "\(leftTasks.count + doneTasks.count) open tasks"
            tableView.reloadData()
        }
    }
    

    func doubleTapped(gesture: UIGestureRecognizer){
        if let index = tableView.indexPathsForSelectedRows?[0].item{
            let indexPath = NSIndexPath(forItem: index, inSection: 0)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if index < leftTasks.count{
                let doneTask = leftTasks[index].valueForKey("task") as? String
                let time = leftTasks[index].valueForKey("time") as? String
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                managedContext.deleteObject(leftTasks[index])
                appDelegate.saveContext()
                
                leftTasks.removeAtIndex(index)
                
                let appDelegate2 = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext2 = appDelegate2.managedObjectContext
                
                let entity =  NSEntityDescription.entityForName("DoneTasks", inManagedObjectContext:managedContext2)
                
                let task = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext2)
                
                task.setValue(doneTask, forKey: "task")
                
                task.setValue(time, forKey: "time")
                
                do {
                    try managedContext.save()
                    doneTasks.append(task)
                    taskProgress.progress = Float(doneTasks.count) / (Float(doneTasks.count)+Float(leftTasks.count))
                    for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
                        if (notification.userInfo!["UUID"] as? String == doneTask) {
                            UIApplication.sharedApplication().cancelLocalNotification(notification)
                            break
                        }
                    }
                    tableView.reloadData()
                }
                catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

            }
            else{
                let doneTask = doneTasks[index-leftTasks.count].valueForKey("task") as? String
                let time = doneTasks[index-leftTasks.count].valueForKey("time") as? String
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                managedContext.deleteObject(doneTasks[index-leftTasks.count])
                appDelegate.saveContext()
                
                doneTasks.removeAtIndex(index-leftTasks.count)
                
                let appDelegate2 = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext2 = appDelegate2.managedObjectContext
                
                let entity =  NSEntityDescription.entityForName("Tasks", inManagedObjectContext:managedContext2)
                
                let task = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext2)
                
                task.setValue(doneTask, forKey: "task")
                
                task.setValue(time, forKey: "time")
                
                do {
                    try managedContext.save()
                    
                    leftTasks.append(task)
                    taskProgress.progress = Float(doneTasks.count) / (Float(doneTasks.count)+Float(leftTasks.count))
                    tableView.reloadData()
                }
                catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }

            }
        }
    }
    
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
    }
    
}

