//
//  CAStoreImage.swift
//  Mon Compte Free
//
//  Created by Free on 10/08/2023.
//

import SwiftUI

/// This View store an Image on the user device
/// Then load the stored image data when
/// Each time the request change, the view download the image,
/// But replace / publish change only if the new data is different of the oldest stored image.
struct CAStoreImage: View {
    
    @StateObject fileprivate var viewModel = CAStoreImageViewModel()
    
    fileprivate var request: URLRequest?
    fileprivate var placeholder: ImageResource
    
    // MARK: - Init
    
    init(path: String?, placeholder: ImageResource = .placeholderLetterF) {
        self.request = URLRequest(path: path ?? "")
        self.placeholder = placeholder
    }
    
    init(url: URL?, placeholder: ImageResource = .placeholderLetterF) {
        self.request = URLRequest(path: url?.absoluteString ?? "")
        self.placeholder = placeholder
    }
    
    init(request: URLRequest?, placeholder: ImageResource = .placeholderLetterF) {
        self.request = request
        self.placeholder = placeholder
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let img = viewModel.imageData.flatMap({UIImage(data: $0)}) {
                Image(uiImage: img)
                    .resizable()
            } else {
                Image(placeholder)
            }
        }
        .onChange(of: request) { newValue in
            viewModel.fetch(request: newValue)
        }
        .onAppear {
            viewModel.fetch(request: request)
        }
    }
    
    static func preloadImages(requests: [URLRequest], completion: @escaping (() -> Void)) {
        CADownloadDataManager.shared.load(requests: requests, completion: completion)
    }
    
    static func preloadImages(requests: [URLRequest]) async {
        await withCheckedContinuation { continuation in
            CADownloadDataManager.shared.load(requests: requests) {
                continuation.resume()
            }
        }
    }
}

@MainActor
private final class CAStoreImageViewModel: ObservableObject {
    
    @Published var imageData: Data?
    
    private var manager = CAURLSessionManager()
    
    private func setImage(url: URL?) {
        if let url = url, let imgData = try? Data(contentsOf: url) {
            imageData = imgData
        } else {
            imageData = nil
        }
    }
    
    func fetch(request: URLRequest?) {
        if var request = request {
            Task {
                do {
                    request.cachePolicy = .returnCacheDataElseLoad
                    let result = try await manager.download(request: request)
                    setImage(url: result)
                } catch {
                    debug("\(#function): \(error.localizedDescription)")
                }
            }
        } else {
            imageData = nil
        }
    }
}

struct CAStoreImage_Previews: PreviewProvider {
    static var previews: some View {
        CAStoreImage(
            path: "https://media.istockphoto.com/id/92911783/fr/photo/mendicité-beaver.jpg" +
                     "?s=612x612&w=0&k=20&c=iNnVt_Dvms2Y8lSlEtNdz0sr7OKWr02l1656c6KBS2w="
        )
        .scaledToFit()
    }
}
