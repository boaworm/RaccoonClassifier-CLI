//
//  main.swift
//  RaccoonClassifier-CLI
//
//  Created by Henrik Thorburn on 2025-02-02.
//

import Foundation

print("Hello, World - from Raccoon Classification ML project in Swift!")


if( CommandLine.arguments.count <= 1){
    let arr = CommandLine.arguments[0].split(separator: "/")
    let appName = arr[ arr.count-1 ]
    print("usage: \(appName) path/to/dir");
    exit(EXIT_SUCCESS)
}

let imageDirPath = CommandLine.arguments[1]
var imageArray : [String] = []
do{
    let tmpArray = try FileManager.default.contentsOfDirectory(atPath: imageDirPath)
    for img in tmpArray{
        imageArray.append(img)
    }
}

struct Observation : Codable {
    var image: String
    var classification: String
    var confidence: Double
}

var observationArray : [Observation] = []

do {
    
    
    let model = try RaccoonClassifier()
    
    var i: Int32 = 1
    for filePath in imageArray {
        if(filePath.hasSuffix(".JPG")){
            let fullPath = imageDirPath + "/" + filePath
            // print("[\(i)]\tProcessing image [\(fullPath)]")
            let url = URL(string: "file:" + fullPath)
            let deerImage = try RaccoonClassifierInput(imageAt: url!)
            let prediction = try model.prediction(input: deerImage)
            // printPrediction(prediction: prediction)
            
            
            let p = getPredictedClass(probabilityMap: prediction.targetProbability)
            let obs = Observation(
                image: filePath,
                classification: p.className,
                confidence: p.probability
            )
            observationArray.append(obs)
    
            i += 1
        }else{
            print("(ignoring file [\(filePath)])")
        }
    }
    
    // print("Storing \(observationArray.count) observations")
    createJsonOutput(observations: observationArray)
    
} catch {
    print("ERROR: \(error)")
}

func createJsonOutput(observations : [Observation]){
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted

    do {
        let data = try jsonEncoder.encode(observations)
        let json = String(decoding: data, as: UTF8.self)
        // print(json)
      
        let url = URL(fileURLWithPath: imageDirPath + "/raccoonNoRaccoon.json")
        try json.write(to: url, atomically: true, encoding: .utf8)
        
        //let filepath = Bundle.main.path(forResource: imageDirPath + "/raccoonNoRaccoon.json", ofType: nil)
        //try? json.write(toFile: filepath!, atomically: true, encoding: String.Encoding.utf8)

    } catch {
        print("Failed to encode observation to json: \(error.localizedDescription)");
    }
    
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

struct Prediction {
    var className = "uninitialized"
    var probability = 0.0
}

func printPrediction(prediction: RaccoonClassifierOutput){
    let p = getPredictedClass(probabilityMap: prediction.targetProbability)
    let formattedLikelyhood = String(format: "%.1f", 100*p.probability)
    print("\tPredicting \(p.className) with \(formattedLikelyhood) % likelyhood")
}

func getPredictedClass(probabilityMap: [String : Double]) -> Prediction {
    var p =  Prediction(className: "undefined", probability: 0.0)
    for pm in probabilityMap{
        if(pm.value > p.probability){
            p.probability = pm.value
            p.className = pm.key
        }
    }
    return p
}
