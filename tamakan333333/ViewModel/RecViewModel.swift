//
//  ViewModel.swift
//  تمكّن
//
//  Created by nouransalah on 08/06/1447 AH.
//

import AVFoundation
import Combine
import SwiftUI
class RecViewModel : ObservableObject{
    @Published var size :CGFloat = 1
    @Published var size1 :CGFloat = 1
    @Published var animationTimer: Timer?
    @Published var time = 0.0
    @Published var timer: Timer?
    
    
//    func startSizeLoop() {
//        // Reset before starting
//        size = 1
//        size1 = 1
//        
//        // Invalidate any old timer
//        animationTimer?.invalidate()
//        
//        // Make a timer that fires every 1 second
//        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            withAnimation(.easeInOut(duration: 0.8)) {
//                self.size = (self.size == 1) ? 1.2 : 1
//                self.size1 = (self.size1 == 1.3) ? 1 : 1.3
//            }
//        }
//    }
//
//    func stopSizeLoop() {
//        animationTimer?.invalidate()
//        animationTimer = nil
//        size = 1
//    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            self.time += 0.01
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        
    }
    
    func startSizeLoop() {
        // Reset before starting
        size = 1
        size1 = 1
        
        // Invalidate any old timer
        animationTimer?.invalidate()
        
        // Make a timer that fires every 1 second
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.8)) {
                self.size = (self.size == 1) ? 1.2 : 1
                self.size1 = (self.size1 == 1.3) ? 1 : 1.3
            }
        }
    }

    func stopSizeLoop() {
        animationTimer?.invalidate()
        animationTimer = nil
        size = 1
    }
}
