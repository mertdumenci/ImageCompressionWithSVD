//
//  AppDelegate.swift
//  NotAPlayground
//
//  Created by Mert Dümenci on 3/29/17.
//  Copyright © 2017 Mert Dümenci. All rights reserved.
//

import UIKit
import SVDCompressionKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        let matrix = Matrix<Int8>(image: UIImage(named: "diddy.jpg")!)
//        let SVD = matrix.svd()
//        
//        let U = SVD.U
//        let sigma = SVD.Σ
//        let VT = SVD.VT
//        
//        print(sigma)
//        
//        let trimmedSigma = trimZeroes(vector: sigma.underlyingVector).reversed()
//        let rank = trimmedSigma.count
//        
//        for singularValue in trimmedSigma {
//            singularValue
//        }
//        
//        let rankFactor = 0.1
//        let newRank = Int(round(Double(rank) * rankFactor))
//        
//        let newSigma = Vector<Double>(trimmedSigma.prefix(newRank))
//        let newSigmaMatrix = Matrix<Double>(diagonal: newSigma, size: sigma.size)
//        
//        for singularValue in newSigma {
//            singularValue
//        }
//        
//        let newImageMatrix = (U * newSigmaMatrix * VT)
//        
//        newImageMatrix.integerRepresentation().imageRepresentation()
//        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.

        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

