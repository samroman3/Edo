//
//  PurchaseManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/19/24.
//
import StoreKit

class PurchaseManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = PurchaseManager()
    @Published var isAdRemoved: Bool = false
    @Published var purchaseSuccessful: Bool = false

    private var products: [SKProduct] = []
    private let removeAdsProductID = "com.edo.removeads"

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
        checkReceipt()
    }

    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: [removeAdsProductID])
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    func purchaseRemoveAds() {
        guard let product = products.first(where: { $0.productIdentifier == removeAdsProductID }) else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                isAdRemoved = true
                purchaseSuccessful = true
                SKPaymentQueue.default().finishTransaction(transaction)
                savePurchaseState()
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    private func savePurchaseState() {
        UserDefaults.standard.set(isAdRemoved, forKey: "isAdRemoved")
    }

    private func checkReceipt() {
        if let isAdRemoved = UserDefaults.standard.value(forKey: "isAdRemoved") as? Bool {
            self.isAdRemoved = isAdRemoved
        }
    }
}
