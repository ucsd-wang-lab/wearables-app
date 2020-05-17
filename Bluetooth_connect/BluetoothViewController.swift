//
//  BluetoothViewController.swift
//  Bluetooth_connect
//
//  Created by Ravi Patel on 5/17/20.
//  Copyright © 2020 neel shah. All rights reserved.
//

import UIKit
import Lottie

class BluetoothViewController: UIViewController {
    
    var lottie_animation: AnimationView!

    @IBOutlet weak var lottie_view: LottieView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lottie_animation = AnimationView(name: "BluetoothAnimation")
        lottie_animation.frame = CGRect(x: 0, y: 0, width: self.lottie_view.bounds.width, height: self.lottie_view.bounds.height)
                
        self.lottie_view.addSubview(lottie_animation)
        self.lottie_view.backgroundColor = .clear
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playAnimation()
    }
    
    func playAnimation(){
        lottie_animation.contentMode = .scaleAspectFit
        lottie_animation.loopMode = .loop
        lottie_animation.play()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
