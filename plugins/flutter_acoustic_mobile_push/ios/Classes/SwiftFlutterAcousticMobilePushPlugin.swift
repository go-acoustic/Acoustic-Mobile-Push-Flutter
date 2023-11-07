import Flutter
import UIKit
import Foundation
import AcousticMobilePush

public class SwiftFlutterAcousticMobilePushPlugin: NSObject, FlutterPlugin, MCEActionProtocol {
    
    static var instance: SwiftFlutterAcousticMobilePushPlugin?
    static var channel: FlutterMethodChannel?
    static var _registrar: FlutterPluginRegistrar?
    static var _headlessRunner: FlutterEngine?
    static var registeredAction: Set<String>? = nil
    
    var dateFormatter = ISO8601DateFormatter()
    
    var _eventQueue: NSMutableArray?
    var listenersSetup = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        _registrar = registrar
        let channel = FlutterMethodChannel(name: "flutter_acoustic_mobile_push", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAcousticMobilePushPlugin()
        _headlessRunner = FlutterEngine(name: "FlutterAcousticSdk", project: nil, allowHeadlessExecution: true)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    @objc func receiveCustomAction(action: NSDictionary){}
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if SwiftFlutterAcousticMobilePushPlugin.registeredAction == nil {
            SwiftFlutterAcousticMobilePushPlugin.registeredAction = []
        }
        
        let methodName = call.method
        if (methodName == "register") {
            let channelId = (MCERegistrationDetails.shared.channelId != nil) ? MCERegistrationDetails.shared.channelId : ""
            let userId = (MCERegistrationDetails.shared.userId != nil) ? MCERegistrationDetails.shared.userId : ""
            let appKey =  (MCEConfig.shared.appKey != nil) ? MCEConfig.shared.appKey : ""
            
            let payload = [
                "userId": userId,
                "channelId": channelId,
                "appKey": appKey
            ]
            
            let encoder = JSONEncoder()
            if let jsonData = try? encoder.encode(payload) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                    result(jsonString)
                }
            }
            
            
        } else if (methodName == "registerCustomAction") {
            if call.arguments != nil {
                let isContained = SwiftFlutterAcousticMobilePushPlugin.registeredAction?.contains(call.arguments as! String) ?? false
                
                if isContained  {
                    result("Custom action type \(call.arguments ?? "") is already registered");
                    
                } else {
                    result("Registering Custom Action: \(call.arguments ?? "")");
                    SwiftFlutterAcousticMobilePushPlugin.registeredAction?.insert(call.arguments as! String)
                    MCEActionRegistry.shared.registerTarget(
                        self,
                        with: #selector(receiveCustomAction(action: )),
                        forAction: call.arguments as! String)
                }
            }
        } else if(methodName == "registerCustomActionTypeAndValue"){
            if call.arguments != nil {
                guard let dic = call.arguments as? [String : String], let type = dic["type"], let value = dic["value"] else {
                    result("Failed to set arguments");
                    return
                }
                
                let isContained = SwiftFlutterAcousticMobilePushPlugin.registeredAction?.contains(type) ?? false
                
                if isContained {
                    result("Registering Custom Action: Type: \(type)  Value: \(value)");
                    let action = ["type": type, "value": value]
                    let payload = ["notification-action": action]
                    MCEActionRegistry.shared.performAction(action, forPayload: payload, source: "internal", attributes: nil, userText: nil)
                } else{
                    result("Please Register Custom Action first");
                }
            }
        } else if (methodName == "unregisterCustomAction") {
            
            if call.arguments != nil {
                let isContained = SwiftFlutterAcousticMobilePushPlugin.registeredAction?.contains(call.arguments as! String) ?? false
                
                if isContained {
                    result("Unregistering Custom Action \(call.arguments ?? "")");
                    SwiftFlutterAcousticMobilePushPlugin.registeredAction?.remove(call.arguments as! String)
                } else {
                    result("Custom action: \(call.arguments ?? "") is not registered");
                    guard let args = call.arguments as? String else {return}
                    MCEActionRegistry.shared.unregisterAction(args)
                }
            }
        } else if (methodName == "sendEvents") {
            
            let dic = call.arguments as! [String : Any]
            
            var type = ""
            var name = ""
            var timestamp = ""
            var date = Date()
            var newDic: [String : Any] = [:]
            var attribution = ""
            var mailingId = ""
            var immediate = false
            
            if dic["type"] != nil {
                type = dic["type"] as! String
            }
            
            if dic["name"] != nil {
                name = dic["name"] as! String
            }
            
            if dic["timestamp"] != nil {
                timestamp = dic["timestamp"] as! String
            }
            
            if dic["attribution"] != nil {
                attribution = dic["attribution"] as! String
            }
            
            if dic["mailingId"] != nil {
                mailingId = dic["mailingId"] as! String
            }
            
            if let number = dic["immediate"] as? Int, number == 1 {
                immediate = true
            }
            
            if timestamp.count > 0 {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'"
                date = dateFormatter.date(from: timestamp)!
            }
            
            if dic["attributes"] != nil {
                let attriArray = dic["attributes"] as! [AnyObject]
                let attributes = attriArray.map { $0 as! [String : Any]}
                
                for attribute in attributes {
                    let attributeType = attribute["type"] as! String
                    let attributeKey = attribute["key"] as! String
                    
                    switch attributeType {
                    case "string":
                        let attributeValue = attribute["value"] as! String
                        newDic[attributeKey] = attributeValue
                    case "number":
                        let attributeValue = attribute["value"] as! Int
                        newDic[attributeKey] = attributeValue
                        
                    case "boolean":
                        let attributeValue = attribute["value"] as! Bool
                        newDic[attributeKey] = attributeValue
                        
                    case "date":
                        let attributeValue = attribute["value"] as! String
                        newDic[attributeKey] = attributeValue
                        
                        
                    default:
                        print("unknown data")
                    }
                    
                }
            }
            
            let event = MCEEvent(
                name: name,
                type: type,
                timestamp: date,
                attributes: newDic,
                attribution: attribution,
                mailingId: mailingId)
            
            MCEEventService.shared.add(event!, immediate: immediate)
        } else if (methodName == "checkLocationPermission") {
            
        } else if (methodName == "updateUserAttributes") {
            
            let attributesArray = call.arguments as! [AnyObject]
            let attributes = attributesArray.map { $0 as! [String : Any]}
            
            var newDic: [String : Any] = [:]
            
            for attribute in attributes {
                let attributeType = attribute["type"] as! String
                let attributeKey = attribute["key"] as! String
                
                switch attributeType {
                case "string":
                    let attributeValue = attribute["value"] as! String
                    newDic[attributeKey] = attributeValue
                case "number":
                    let attributeValue = attribute["value"] as! Int
                    newDic[attributeKey] = attributeValue
                    
                case "boolean":
                    let attributeValue = attribute["value"] as! Bool
                    newDic[attributeKey] = attributeValue
                    
                case "date":
                    let attributeValue = attribute["value"] as! String
                    newDic[attributeKey] = attributeValue


                default:
                    print("unknown data")
                }
                
            }
            
            MCEAttributesQueueManager.shared.updateUserAttributes(newDic)
            
        } else if (methodName == "deleteUserAttributes") {
            
            let keyNames = call.arguments as! [String]
            
            MCEAttributesQueueManager.shared.deleteUserAttributes(keyNames)
            
        } else if (methodName == "sdkState") {
            let state = MCESdk.shared.sdkState()
            let stateString = sdkStateToString(state: state)
            
            result(stateString)
            
        } else if (methodName == "sdkStateIsRunning") {
            MCESdk.shared.sdkStateIsRunning { (error) in
                if error != nil {
                    print(error?.localizedDescription);
                    result("false");
                    return;
                }
                
                result("true");
              }
        } else {
            
        }
    }
    
    public func registerAction() {
        
    }
    
    public func constantsToExport() -> [String:String?] {
        let config = MCESdk.shared.config
        let dictionary: [String:String?] = [
            "pluginVersion": "3.8.7",
            "sdkVersion": MCESdk.shared.sdkVersion(),
            "appKey": (config.appKey != nil) ? config.appKey : nil
        ]
        return dictionary
    }
    
    public func supportedEvents() {
        if (!listenersSetup) {
            listenersSetup = true
        }
    }
    
    func addSafeObserverFor(name: Notification.Name, usingBlock:
                            @escaping (Notification, SwiftFlutterAcousticMobilePushPlugin) -> Void) {
        let center = NotificationCenter.default
        let mainQueue = OperationQueue.main
        
        center.addObserver(forName: name, object: nil, queue: mainQueue) { (note) in
            usingBlock(note, self)
        }
        
    }
    
    func sdkStateToString(state: MCESdkState) -> String {
        switch state {
        case .NotInitialized:
            return "NotInitialized"
        case .Initializing:
            return "Initializing"
        case .Running:
            return "Running"
        case .Stopped:
            return "Stopped"
        }
    }
}
