//
//  ContentView.swift
//  AlzheimersTest
//
//  Created by Amit Gupta on 3/1/21.
//

//
//  ContentView.swift
//  Copyright © 2020 Pyxeda. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct ContentView: View {
    @State var animalName = " "
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage? = UIImage(systemName: "stethoscope")
    
    var body: some View {
        HStack {
            VStack (alignment: .center,
                    spacing: 20){
                Text("Alzheimer Check")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                        Text(animalName)
                        Image(uiImage: inputImage!).resizable()
                            .aspectRatio(contentMode: .fit)
                        //Text(animalName)
                        Button("Check MRI"){
                            self.buttonPressed()
                        }
                        .padding(.all, 14.0)
                        .foregroundColor(.white)
                            .background(Color.green)
                        .cornerRadius(10)
            }
            .font(.title)
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        self.showingImagePicker = true
    }
    
    func processImage() {
        self.showingImagePicker = false
        self.animalName="Checking..."
        guard let inputImage = inputImage else {return}
        print("Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        var uploadURL = "https://3h6ys7t373.execute-api.us-east-1.amazonaws.com/Predict/03378121-5f5b-4e24-8b5b-7a029003f2a4";
        uploadURL = "https://q6x4m57367.execute-api.us-east-1.amazonaws.com/Predict/29356b45-0189-461a-ad81-44c240f38ceb"
        uploadURL="https://lk5rtu02c1.execute-api.us-east-1.amazonaws.com/Predict/e5e0bce1-53a2-469e-b3b6-e0cf5a32cd26"
        
        AF.upload(imageB64, to: uploadURL).responseJSON { response in
            
            debugPrint(response)
            switch response.result {
               case .success(let responseJsonStr):
                   print("\n\n Success value and JSON: \(responseJsonStr)")
                   let myJson = JSON(responseJsonStr)
                   var predictedValue = myJson["predicted_label"].string
                   print("Saw predicted value \(String(describing: predictedValue))")
                if(predictedValue=="zero") {
                    predictedValue="Low"
                } else if(predictedValue=="nonzero") {
                    predictedValue="High"
                }
                   let predictionMessage = "Risk: " + predictedValue!
                   self.animalName=predictionMessage
               case .failure(let error):
                   print("\n\n Request failed with error: \(error)")
               }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
