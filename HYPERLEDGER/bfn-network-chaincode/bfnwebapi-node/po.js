const mjson = {
  supplier: "e4cc2910-399b-11e9-b18d-d53f80ae5199",
  purchaseOrderId: "n/a",
  customer: "c4e95190-399b-11e9-b18d-d53f80ae5199",
  user: "n/a",
  date: "n/a",
  intDate: "n/a",
  deliveryDateRequired: "n/a",
  amount: 43605.08,
  description: "Generated Demo Purchase Order",
  deliveryAddress: "n/a",
  purchaseOrderNumber: "PO-7146147-28",
  purchaseOrderURL: null,
  supplierName: "DHH Transport Logistics",
  purchaserName: "Atteridgeville MetalWorks Ltd",
  contractURL: "n/a"
};
function checkJSON() {
  console.log(`\n💦  💦  💦  💦  💦  💦  checking json\n`)
  const list = [];
  for (var i = 0; i < 10; i++) {
    list.push(JSON.stringify(mjson));
  }
  const obj = JSON.parse(JSON.stringify(list));
  console.log(obj);
  console.log(`\n🙄 🙄 🙄 🙄  done checking json object \n\n`);

  const str = JSON.stringify(list);
  console.log(str);
  onsole.log(`\n🙄 🙄 🙄 🙄  done checking json object \n\n`);
}

checkJSON()
