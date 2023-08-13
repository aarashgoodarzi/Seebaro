//
//  ProductItemView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

struct ProductItemView: View {
    
    var product: Product
    
    private let service = ProductsService()
    
    @State var loading: Bool = false
    
    @EnvironmentObject var account: Account
    @Environment(\.openURL) var openURL
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: product.icon)) { image in
                image.resizable()
            } placeholder: {
                Rectangle()
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack {
                Text(product.title)
                    .font(.title3)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(product.subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            // MARK: - Install button
            ZStack {
                ProgressView()
                    .opacity(loading ? 1 : 0)
                
                Button(action: install) {
                    Text("Install")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
                .buttonStyle(.borderedProminent)
                .padding()
                .opacity(loading ? 0 : 1)
            }
        }
    }
    
    func install() {
        Task {
            withAnimation {
                self.loading = true
            }
            do {
                let manifest = try await service.getManifest(
                    id: product.id,
                    token: account.userToken
                )
                if let manifest {
                    openURL(manifest)
                }
            } catch {
                print(error)
            }
            withAnimation {
                self.loading = false
            }
        }
    }
}

//#Preview {
//    @StateObject var account = Account()
//    
//    return ProductItemView(
//        product: Product(
//            id: <#T##Int#>,
//            type: <#T##AppType#>,
//            title: <#T##String#>,
//            subtitle: <#T##String#>,
//            version: <#T##String#>,
//            description: <#T##String#>,
//            ipaSize: <#T##String#>,
//            icon: <#T##String#>,
//            bundleIdentifier: <#T##String#>,
//            createdAt: <#T##String#>,
//            updatedAt: <#T##String#>,
//            screenshots: <#T##[Screenshot]#>
//        )
//    )
//    .environmentObject(account)
//}
