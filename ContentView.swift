//
//  ContentView.swift
//  InstaFilter
//
//  Created by Liko Setiawan on 14/04/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI

struct ContentView: View {
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                PhotosPicker(selection: $selectedItem){
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No Picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                //change the color blue to black
                .buttonStyle(.plain)
                
                Spacer()
                
                HStack{
                    Text("Intensity")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcesing)
                }
                .padding(.vertical)
                
                HStack{
                    Button("Change Filter", action : changeFilter)
                    Spacer()
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .navigationTitle("InstaFilter")
            .padding([.horizontal, .bottom])
            .confirmationDialog("select a filter", isPresented: $showingFilters){
                Button("Cyrstallize") { setFilter(CIFilter.crystallize())}
                Button("Edges") { setFilter(CIFilter.edges())}
                Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate") { setFilter(CIFilter.pixellate())}
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone())}
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask())}
                Button("Vignette") { setFilter(CIFilter.vignette())}
                Button("Cancel", role: .cancel){ }
            }
        }
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcesing()
        }
    }
    
    func changeFilter() {
        showingFilters = true
    }
    
    func applyProcesing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey){
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
                
       let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
        
    }
    
    @MainActor func setFilter(_ filter : CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 3 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}



//
//func loadImage() {
//    let inputImage = UIImage(resource: .joji)
//    let beginImage = CIImage(image: inputImage)
//    
//    let context = CIContext()
//    let currentFilter = CIFilter.sepiaTone()
//
//    currentFilter.inputImage = beginImage
//    let amount = 1.0
//    let inputKeys = currentFilter.inputKeys
//    
//    if inputKeys.contains(kCIInputIntensityKey){
//        currentFilter.setValue(amount, forKey: kCIInputIntensityKey)
//    }
//    if inputKeys.contains(kCIInputRadiusKey){
//        currentFilter.setValue(amount * 200, forKey: kCIInputRadiusKey)
//    }
//    if inputKeys.contains(kCIInputScaleKey){
//        currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)
//    }
//    
//    guard let outputImage = currentFilter.outputImage else{ return }
//    
//    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
//    
//    let uiImage = UIImage(cgImage: cgImage)
//    
//    image = Image(uiImage: uiImage)
//}

//
//    PhotosPicker(selection: $pickerItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.screenshots)])) {
//        Label("Select a picture", systemImage: "photo")
//    }
//    
//    ScrollView{
//        ForEach(0..<selectedImages.count, id: \.self) { i in
//        selectedImages[i]
//                .resizable()
//                .scaledToFit()
//            
//        }
//    }
//}
//.onChange(of: pickerItems){
//    Task{
//        selectedImages.removeAll()
//        
//        for item in pickerItems {
//            if let loadedImage = try await item.loadTransferable(type: Image.self){
//                selectedImages.append(loadedImage)
//            }
//        }
//    }
//}
