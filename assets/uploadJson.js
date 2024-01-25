const admin = require('firebase-admin');
const serviceAccount = require("./key_service_account.json");
const data = require("./breakfast_menu.json");
const collectionKey = "restaurantes"; //Name of the collection

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});
const firestore = admin.firestore();
const settings = { timestampsInSnapshots: true };
firestore.settings(settings);
if (data && (typeof data === "object")) {

    Object.keys(data.restaurantes).forEach(docKey => {
        
        /* console.log(data.restaurante[docKey])
        console.log(docKey) */
        firestore.collection(collectionKey).add(data.restaurantes[docKey]).then((res) => {
            console.log("Document " + docKey + " successfully written!");
        }).catch((error) => {
            console.error("Error writing document: ", error);
        });
    });
    
}