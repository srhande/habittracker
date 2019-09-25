//
//  ViewController.swift
//  habittracker
//
//  Created by Katy Felkner on 2/16/19.
//  Copyright © 2019 Katy Felkner. All rights reserved.
//

import UIKit
import CoreData
import CoreML

class ViewController: UIViewController {
   
    
    @IBOutlet weak var mood: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var label: UILabel!
    @IBAction func stepperPressed(_ stepper: UIStepper) {
        label.text = String (stepper.value)
    }
    
    // array of all the days
    // for now we are loading them all into memory but this may become too big
    var days: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sample ML predictions
        let model = Regression2()
        //let inputWater = MLMultiArray(2.0, 90.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0)
        //let inputSleep = MLMultiArray(3.0, 80.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0)
        //let inputExercise = MLMultiArray(2.0, 80.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0)
        
        do {
            let input = try MLMultiArray.init(shape: [11], dataType:.double)
            input[0] = 6.0
            input[1] = 20.0
            input[2] = 1.0
            input[3] = 0.0
            input[4] = 0.0
            input[5] = 1.0
            input[6] = 1.0
            input[7] = 0.0
            input[8] = 1.0
            input[9] = 0.0
            input[10] = 0.0
            
            // predict with more water
            input[1] = 30.0
            let outputWater = try model.prediction(input: input)
            //print(outputWater.featureNames)
            //print(outputWater.featureValue(for: outputWater.featureNames["output"]))
            print(outputWater.featureValue(for: "output")?.multiArrayValue![0] ?? 100)
            
            // predict with more sleep
            input[1] = 20.0
            input[0] = 7.0
            var outputSleep = try model.prediction(input: input)
            print(outputSleep.featureValue(for: "output")?.multiArrayValue![0] ?? 100)
            
            // predict with more exercise
            input[7] = 1.0
            input[0] = 6.0
            var outputExercise = try model.prediction(input: input)
            print(outputExercise.featureValue(for: "output")?.multiArrayValue![0] ?? 100)
            
        } catch {
            print("unexpected ML error")
        }
    
        
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
//        mood.addTarget(self, action: #selector(self.moodValue(_:)), for: .valueChanged)
    }
    
    // do we even need this method?
    func newDay() -> NSManagedObject? {
        // should be called whenever tracking for a new day is initiated
        // returns object for that day
        // this object is then passed to other methods to add data to the day


        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return nil
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            today = fetched[0]
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)

        }
        
        // 3
        today.setValue(NSDate(), forKeyPath: "date")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return today
    }
    
    // add a numerical mood entry to an existing day
    func addMoodNum(mood: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX

 
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(mood, forKeyPath: "moodNum")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a comma separated string of qualitative mood data for a certain day
    func addMoodString (moodStr: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(moodStr, forKeyPath: "moodStrs")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // add amount of water consumed (in ounces)
    func addWater (today: NSManagedObject, water: Int) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(water, forKeyPath: "water")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addSocialize(social: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(social, forKeyPath: "socialize")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a double - how many hours did user sleep
    // caller is responsible for calculating this or asking user to supply it
    func addSleepTime (hours: Double) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(hours, forKeyPath: "Double")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addShower (shower: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(shower, forKeyPath: "shower")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addReading(reading: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(reading, forKeyPath: "reading")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addMeds(taken: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(taken, forKeyPath: "meds")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addMakeBed(made: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(made, forKeyPath: "makeBed")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addFruitVeg (eaten: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(eaten, forKeyPath: "fruitVeg")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addExercise(exercise: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(exercise, forKeyPath: "exercise")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addCaffeine(caff: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(caff, forKeyPath: "caffeine")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // add a boolean - did user socialize?
    func addAlcohol(alcohol: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as! AppDelegate? else {
            return
        }
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/DD/YYYY"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
        fetch.predicate = NSPredicate(format: "date == %@", dateFormatter.string(from: Date()))
        
        var today: NSManagedObject
        do {
            let fetched = try managedContext.fetch(fetch) as! [NSManagedObject]
            if (fetched.count == 0) {
                print("found an entry for today")
                today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
            }
            else {
                print("creating an entry for today")
                today = fetched[0]
            }
            
        }
        catch {
            // an entry for today doesnt exist, so we need to create one
            today = NSEntityDescription.insertNewObject(forEntityName: "Day", into: managedContext)
        }
        
        // 3
        today.setValue(alcohol, forKeyPath: "alcohol")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func completeEntry(entity: NSEntityDescription, date: Date, sleepHrs: Double, water: Int, socialize: Bool, shower: Bool, reading: Bool, moodStrs: String, moodNum: Int, meds: Bool, makeBed: Bool, fruitVeg: Bool, exercise: Bool, caffeine: Bool, alcohol: Bool) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let today = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        // populate this object with all the values
        today.setValue(alcohol, forKeyPath: "alcohol")
        today.setValue(caffeine, forKeyPath: "caffeine")
        today.setValue(date, forKeyPath: "date")
        today.setValue(exercise, forKeyPath: "exercise")
        today.setValue(fruitVeg, forKeyPath: "fruitVeg")
        today.setValue(makeBed, forKeyPath: "makeBed")
        today.setValue(meds, forKeyPath: "meds")
        today.setValue(moodNum, forKeyPath: "moodNum")
        today.setValue(moodStrs, forKeyPath: "moodStrs")
        today.setValue(reading, forKeyPath: "reading")
        today.setValue(shower, forKeyPath: "shower")
        today.setValue(sleepHrs, forKeyPath: "sleep")
        today.setValue(socialize, forKeyPath: "socialize")
        today.setValue(water, forKeyPath: "water")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    // wipe database and populate it with a set of testing data
    func populateTestData () {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Day", in: managedContext)!
        
        
        // get training data CSV
        do {
            // make a date formatter for convenience
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/DD/YYYY"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            
            let u = URL(fileURLWithPath: "trainingdata.csv")
            
            let s = try String(contentsOf: u)
            // separate into lines
            let lines: [String.SubSequence] = s.split(separator:"\n")
            
            // process each line
            for l in lines {
                // separate on commas
                let cells: [String.SubSequence] = l.split(separator:",")
                
                
               // completeEntry(entity: entity, date: dateFormatter.date(from: String(cells[0])), sleepHrs: Double(cells[3]), water: Int(cells[4]), socialize: Bool(cells[9]), shower: Bool(cells[5]), reading: Bool(cells[12]), moodStrs: String(cells[]), moodNum: Int, meds: Bool, makeBed: Bool, fruitVeg: Bool, exercise: Bool, caffeine: Bool, alcohol: Bool)
                
            }
            
        } catch {
            print("error processing: trainingdata.csv: \(error)")
        }
        
        
        
    }
    
    func processFile(at url: URL)
    {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func moodValue(_ sender: UISegmentedControl) {
        addMoodNum(mood: sender.selectedSegmentIndex + 1)
    
    }
    
    @IBAction func showerTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addShower(shower: false)
        }
        else {
            addShower(shower: true)
        }
    }
    
    @IBAction func bedTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addMakeBed(made: false)
        }
        else {
            addMakeBed(made: true)
        }
    }

  
    @IBAction func alcTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addAlcohol(alcohol: false)
        }
        else {
            addAlcohol(alcohol: true)
        }
    }
    
    @IBAction func caffTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addCaffeine(caff: false)
        }
        else {
            addCaffeine(caff: true)
        }
    }
    
    @IBAction func socTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addSocialize(social: false)
        }
        else {
            addSocialize(social: true)
        }
    }

    @IBAction func exerciseTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addExercise(exercise: false)
        }
        else {
            addExercise(exercise: true)
        }
    }
    
    @IBAction func medTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addMeds(taken: false)
        }
        else {
            addMeds(taken: true)
        }
    }
    
    @IBAction func readTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addReading(reading: false)
        }
        else {
            addReading(reading: true)
        }
    }
    
    @IBAction func  vegTracker(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            addFruitVeg(eaten: false)
        }
        else {
            addFruitVeg(eaten: true)
        }
    }
    
    @IBAction func textFieldDidEndEditing(_ textField: UITextField) {
        guard let myText = textField.text else {
            return
        }
        addSleepTime(hours: Double(myText)!)
    }
    
    @IBAction func textFieldShouldReturn(textField: UITextField) {
        textField.resignFirstResponder()
        return
    }
}

class TrackerViewController: UIViewController {
    
}
