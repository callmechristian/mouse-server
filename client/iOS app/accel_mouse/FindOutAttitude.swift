//
//  FindOutAttitude.swift
//  accel_mouse
//
//  Created by Philipp Ahrendt on 09.10.22.
//

import Foundation
import CoreGraphics
import CoreMotion

class AttitudeCalculator: NSObject
{
    let frequency = 1.0
    let manager = CMMotionManager()
    var timer: Timer!

    var pitch = 0.0
    var roll = 0.0
    override init()
    {
        print("init")
        super.init()
        handleMotionUpdates()
        rawValues()
    }
    
    func handleMotionUpdates()
    {
        
        manager.deviceMotionUpdateInterval = frequency
        
        manager.showsDeviceMovementDisplay = true
        manager.magnetometerUpdateInterval = frequency
        manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { (motion, error) in
            // Handle device motion updates
            // Get accelerometer sensor data
            let a_x = motion?.userAcceleration.x
            let a_y = motion?.userAcceleration.y
            let a_z = motion?.userAcceleration.z
            
            // Get gyroscope sensor data
            let r = motion?.rotationRate.x
            let p = motion?.rotationRate.y
            let q = motion?.rotationRate.z
            
            // Get magnetometer sensor data
            let accuracy = motion?.magneticField.accuracy
            let m_x = motion!.magneticField.field.x
            let m_y = motion!.magneticField.field.y
            let m_z = motion!.magneticField.field.z
            
            
            let attitude = motion!.attitude
            let pitch = motion!.attitude.pitch
            let roll = motion!.attitude.roll
            let yaw = motion!.attitude.yaw
            
            // Get gravity vector
            let g_x = motion?.gravity.x
            let g_y = motion?.gravity.y
            let g_z = motion?.gravity.z            

            // Calculate x and y
            let y = pitch
            let x = roll*(1.0-abs(pitch))

            print(m_y, " ", cos(pitch), " ", m_z, " ", sin(pitch))
            let Xm = m_y*cos(pitch)+m_x*sin(roll)*sin(pitch)-m_z*cos(roll)*sin(pitch)
            let Ym = m_x*cos(roll)+m_z*sin(roll)
            
            let psi = -atan2(Ym, Xm)
            
            print(motion?.magneticField.field)
            print(">>>>> ", psi * 180.0 / .pi)
            print("<<<<< ", yaw * 180.0 / .pi)
            print("")
        }
    }
    
    var motion2 = CMMotionManager()
    func rawValues()
    {
        if self.motion2.isAccelerometerAvailable && self.motion2.isGyroAvailable
        {
            self.motion2.accelerometerUpdateInterval = frequency
            self.motion2.gyroUpdateInterval = frequency
            self.motion2.magnetometerUpdateInterval = frequency
            
            self.motion2.startAccelerometerUpdates()
            self.motion2.startGyroUpdates()
            self.motion2.startMagnetometerUpdates()
            
            
            self.timer = Timer(fire: Date(), interval: (frequency),
                               repeats: true, block: { (timer) in
                if let accelData = self.motion2.accelerometerData, let gyroData = self.motion2.gyroData, let magData = self.motion2.magnetometerData
                {
                    let a_x = accelData.acceleration.x
                    let a_y = -accelData.acceleration.y
                    let a_z = -accelData.acceleration.z
                    
                    _ = gyroData.rotationRate.x
                    _ = gyroData.rotationRate.y
                    let g_z = gyroData.rotationRate.z
                    
                    let m_x = magData.magneticField.x
                    let m_y = -magData.magneticField.y
                    let m_z = -magData.magneticField.z

                    let pitch = asin(a_y)
                    let roll = atan(a_x/a_z)
                    let Xm = m_x*cos(pitch)+m_y*sin(roll)*sin(pitch)+m_z*cos(roll)*sin(pitch)
                    let Ym = m_y*cos(roll)-m_z*sin(roll)
                    
                    
                    let yaw = atan2(Ym,Xm) * 180 / .pi
                    
                    print(pitch, ", ", roll)
                    print("s: ", yaw)
                }
            })
        }
        RunLoop.current.add(self.timer, forMode: .default)
    }
}