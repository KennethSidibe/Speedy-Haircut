//
//  AdministratorProfileView.swift
//  Speedy Haircut
//
//  Created by Kenneth Sidibe on 2022-08-04.
//

import SwiftUI

struct AdministratorProfileView: View {
    
    @EnvironmentObject private var authBrain:AuthenticationBrain
    @EnvironmentObject private var dbBrain:DatabaseBrain
    
    var body: some View {
        
        let currentAdministrator = dbBrain.getUser()
        let name = currentAdministrator.firstName ?? "Admin"
        
        
    }
}

struct AdministratorProfileView_Previews: PreviewProvider {
    static var previews: some View {
        AdministratorProfileView()
    }
}
