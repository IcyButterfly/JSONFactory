struct <#Root#>: Mapping {
    var gender: Int 
    var age: String? 
    var city: City? 
    var name: String 
    var appointment: String? 
    var logs: [Logs]? 
}


struct City: Mapping {
    var cityName: String 
    var cityId: Int 
}


struct Logs: Mapping {
    var log: String 
    var time: String 
    var avator: String 
}
