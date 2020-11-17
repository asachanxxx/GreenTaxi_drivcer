class Company{
  String companyName;
  String address;
  String appName;
  String country;
  String city;
  String imagePath;
  String commissionCutMode; //(Model Base , Company base. witch indicate that the commission cut for a given vehicle model or company)
  double SCR; //(this is the deduction from the one trip. System Commission Rate (SCR).)
  double ODR; //(Original Drivers Rate )

  Company({
    this.companyName,
    this.address,
    this.appName,
    this.country,
    this.city,
    this.imagePath,
    this.commissionCutMode,
    this.SCR,
    this.ODR
  });

}
