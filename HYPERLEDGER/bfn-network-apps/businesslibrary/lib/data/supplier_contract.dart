class SupplierContract {
  String contractId;
  String startDate;
  String endDate;
  String date;
  String estimatedValue;
  String customerName;
  String supplierName;
  String description;
  String customer;
  String supplier;
  String user, contractURL;

  SupplierContract(
      {this.contractId,
      this.startDate,
      this.endDate,
      this.date,
      this.estimatedValue,
      this.customerName,
      this.supplierName,
      this.description,
      this.customer,
      this.contractURL,
      this.supplier,
      this.user});

  SupplierContract.fromJson(Map data) {
    this.contractId = data['contractId'];
    this.startDate = data['startDate'];
    this.customer = data['customer'];
    this.user = data['user'];
    this.endDate = data['endDate'];
    this.estimatedValue = data['estimatedValue'];
    this.date = data['date'];
    this.customerName = data['customerName'];
    this.description = data['description'];
    this.supplierName = data['supplierName'];
    this.supplier = data['supplier'];
    this.contractURL = data['contractURL'];
  }

  Map<String, String> toJson() => <String, String>{
        'contractId': contractId,
        'startDate': startDate,
        'customer': customer,
        'user': user,
        'endDate': endDate,
        'estimatedValue': estimatedValue,
        'date': date,
        'customerName': customerName,
        'description': description,
        'supplierName': supplierName,
        'supplier': supplier,
        'contractURL': contractURL,
      };
}
