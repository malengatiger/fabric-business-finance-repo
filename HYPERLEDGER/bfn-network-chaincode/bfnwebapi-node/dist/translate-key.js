"use strict";
const path = require("path");
const fs = require("fs");
function translateKey(betaKey64) {
    console.log(`translate key ...`);
    // const buff = Buffer.from(betaCert64, "base64");
    // const betaCert = buff.toString("ascii");
    const buff2 = Buffer.from(betaKey64, "base64");
    const betaKey = buff2.toString("ascii");
    const mpath = path.join('adminkey.pk');
    fs.writeFileSync(mpath, betaKey);
    console.log(`\n\n😡 😡 😡 😡 😡 😡 😡 😡 betaKey: \n\n${betaKey} \n\n  😡 😡 😡 😡 😡 😡 😡 😡\n`);
}
function translateCert(betaCert64) {
    console.log(`translate certificate ...`);
    const buff = Buffer.from(betaCert64, "base64");
    const betaCert = buff.toString("ascii");
    const mpath = path.join('admincert.pem');
    fs.writeFileSync(mpath, betaCert);
    console.log(`\n\n💕 💕  💕 💕  💕 💕  💕 💕 betaCert: \n\n${betaCert} \n\n  💕 💕  💕 💕 💕 💕  💕 💕 💕 💕  💕 💕`);
}
translateKey("LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tDQpNSUdIQWdFQU1CTUdCeXFHU000OUFnRUdDQ3FHU000OUF3RUhCRzB3YXdJQkFRUWdINlAxVXBaeUl4OEFWSjBrDQppdmEzc0hHL3REOUgxUG9rMS8wYTd2M3FrTWVoUkFOQ0FBVHZ6cWVldDEyVTRkRTlrZ0R1bnJjbDFRVE84c3dODQp0Zk9LOW5CUWtkbG9hUDFqTGZWRmpPZmJXeHhRODNFbERPWVRFOGFCdG5kVTVDcUtmSDdXM3RSdA0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQ0K");
translateCert("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlCNnpDQ0FaR2dBd0lCQWdJVVF4aDRhVnl2ZmpsM0Q2SDZxOFlWYUpGbVR6QXdDZ1lJS29aSXpqMEVBd0l3DQphREVMTUFrR0ExVUVCaE1DVlZNeEZ6QVZCZ05WQkFnVERrNXZjblJvSUVOaGNtOXNhVzVoTVJRd0VnWURWUVFLDQpFd3RJZVhCbGNteGxaR2RsY2pFUE1BMEdBMVVFQ3hNR1JtRmljbWxqTVJrd0Z3WURWUVFERXhCbVlXSnlhV010DQpZMkV0YzJWeWRtVnlNQjRYRFRFNU1ESXlNekV6TkRrd01Gb1hEVEl3TURJeU16RXpOVFF3TUZvd0lURVBNQTBHDQpBMVVFQ3hNR1kyeHBaVzUwTVE0d0RBWURWUVFERXdWaFpHMXBiakJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5DQpBd0VIQTBJQUJPL09wNTYzWFpUaDBUMlNBTzZldHlYVkJNN3l6QTIxODRyMmNGQ1IyV2hvL1dNdDlVV001OXRiDQpIRkR6Y1NVTTVoTVR4b0cyZDFUa0tvcDhmdGJlMUcyallEQmVNQTRHQTFVZER3RUIvd1FFQXdJSGdEQU1CZ05WDQpIUk1CQWY4RUFqQUFNQjBHQTFVZERnUVdCQlRRYkozbncvSmNDSU5jQUtoeGtsVkZrTDFRVURBZkJnTlZIU01FDQpHREFXZ0JSSElxRUlWZ05DNmRnY2w5UEtZYXY1MEkrc3B6QUtCZ2dxaGtqT1BRUURBZ05JQURCRkFpRUFzRXlSDQpPNEN6Tnc4cFF2OUJZSHVNZWs4eWN1Undhb3hFZVoyWGFVcnFNRHNDSUJTdEl0SDFTREJ1UHJlZlFPejU2UDYxDQpVK3JNRFR0aGhsZFRSTmM0Tk1nMQ0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ0K");
//# sourceMappingURL=translate-key.js.map