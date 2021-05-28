//
//  MockedData.swift
//  ConcordiumWallet
//
//  Created by Concordium on 3/9/20.
//  Copyright © 2020 concordium. All rights reserved.
//

import Foundation

import RealmSwift

class MockedData: ShowToast {
    //swiftlint:disable:next function_body_length
    static func mockTransactionsVMs() -> TransactionsListViewModel {
        let amount = GTU(intValue: 1)
        let total = GTU(intValue: 1)
        let cost = GTU(intValue: 1)
        
        let transactionList = TransactionsListViewModel()
        var transactions = [TransactionViewModel]()
        
        var transaction1 = TransactionViewModel()
        transaction1.title = "hgfgfhgfgfghfgfghfhgfhgfghfhgfhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction1.status = .received
        transaction1.amount = amount
        transaction1.total = total
        transaction1.cost = cost
        
        var transaction2 = TransactionViewModel()
        transaction2.title = "7ghvtry7ygyhgjy7ygghg767hghgu7thhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction2.status = .committed
        transaction2.outcome = .ambiguous
        transaction2.amount = amount
        transaction2.total = total
        transaction2.cost = cost
        
        var transaction3 = TransactionViewModel()
        transaction3.title = "hgfgfhgfgfghfgfghfhgfhgfghfhgfhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction3.status = .absent
        transaction3.amount = amount
        transaction3.total = total
        transaction3.cost = cost
        
        var transaction4 = TransactionViewModel()
        transaction4.title = "hgfgfhgfgfghfgfghfhgfhgfghfhgfhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction4.status = .committed
        transaction4.outcome = .success
        transaction4.amount = amount
        transaction4.total = total
        transaction4.cost = cost
        
        var transaction5 = TransactionViewModel()
        transaction5.title = "hgfgfhgfgfghfgfghfhgfhgfghfhgfhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction5.status = .finalized
        transaction5.outcome = .success
        transaction5.amount = amount
        transaction5.total = total
        transaction5.cost = cost
        
        var transaction8 = TransactionViewModel()
        transaction8.title = "hgfgfhgfgfghfgfghfhgfhgfghfhgfhgfgfhgfgfghfgfghfhgfhgfghfhgf"
        transaction8.status = .finalized
        transaction8.outcome = .success
        transaction8.amount = GTU(intValue: -10)
        transaction8.total = total
        transaction8.cost = cost
        
        var transaction6 = TransactionViewModel()
        transaction6.title = "Mohamed"
        transaction6.status = .committed
        transaction6.outcome = .reject
        transaction6.amount = amount
        transaction6.total = total
        transaction6.cost = cost
        
        var transaction7 = TransactionViewModel()
        transaction7.title = "Mohamed"
        transaction7.status = .finalized
        transaction7.outcome = .reject
        transaction7.amount = amount
        transaction7.total = total
        transaction7.cost = cost
        
        transactions.append(transaction1)
        transactions.append(transaction2)
        transactions.append(transaction3)
        transactions.append(transaction4)
        transactions.append(transaction5)
        transactions.append(transaction8)
        transactions.append(transaction6)
        transactions.append(transaction7)
        
        transactionList.transactions = transactions
        return transactionList
    }
    
    static func encodedImage() -> String {
        //swiftlint:disable:next line_length
        "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"
    }

    func recipientsMockedData() -> [RecipientDataType] {
        var recipients = [RecipientEntity]()
        let names = ["Carrie Reily",
                     "John Mckarthy",
                     "Kelly fisher"]
        let addresses = ["4HJ43GH656fJK900AGC9800",
                         "5HJ53TL996fJK900AGC9876",
                         "6HJ63GH65KKJK900AGC9899"]
        for _ in 0..<10 {
            let name = names[Int(arc4random()) % 3]
            let address = addresses[Int(arc4random()) % 3]
            let mockRecipient = RecipientEntity(name: name, address: address)
            recipients.append(mockRecipient)
        }
        return recipients
    }

    static func addMockButton(in vc: BaseViewController) {
        let addMockDataButton = UIButton()
        addMockDataButton.frame = CGRect(x: 0, y: 0, width: 150, height: 30)
        addMockDataButton.center = vc.view.center
        addMockDataButton.backgroundColor = .lightGray
        addMockDataButton.setTitle("Add mock data", for: .normal)
        addMockDataButton.addTarget(self, action: #selector(addMockData), for: .touchUpInside)
        vc.view.addSubview(addMockDataButton)
    }

    @objc static func addMockData() {
        //swiftlint:disable force_try
        let realm = try! Realm(configuration: AppSettings.realmConfiguration)
        let createAtBaseLine = Date()
        let minute: Double = 60
        try! realm.write {
            realm.deleteAll()
            let identity = createIdentity()
            realm.add(identity)
            realm.add(AccountEntity(name: "Finalized account", submissionId: "a01", transactionStatus: .finalized, identity: identity))
            realm.add(AccountEntity(name: "Committed account", submissionId: "a02", transactionStatus: .committed, identity: identity))
            realm.add(AccountEntity(name: "Received account", submissionId: "a03", transactionStatus: .received, identity: identity))
            realm.add(AccountEntity(name: "Absent account", submissionId: "a04", transactionStatus: .absent, identity: identity))
            // submission status returned by server: received
            realm.add(TransferEntity(amount: "1000", submissionId: "t01",
                                     createdAt: createAtBaseLine.addingTimeInterval(-1 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a01"))
            // submission status returned by server: committed success
            realm.add(TransferEntity(amount: "2000", submissionId: "t02",
                                     createdAt: createAtBaseLine.addingTimeInterval(-2 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a02"))
            // submission status returned by server: committed ambiguous
            realm.add(TransferEntity(amount: "3000", submissionId: "t03",
                                     createdAt: createAtBaseLine.addingTimeInterval(-3 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a03"))
            // submission status returned by server: committed reject
            realm.add(TransferEntity(amount: "4000", submissionId: "t04",
                                     createdAt: createAtBaseLine.addingTimeInterval(-4 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a04"))
            // submission status returned by server: absent
            realm.add(TransferEntity(amount: "5000", submissionId: "t05",
                                     createdAt: createAtBaseLine.addingTimeInterval(-5 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a05"))
            // submission status returned by server: finalized success. NB: submission status causes this to be deleted
            realm.add(TransferEntity(amount: "6000", submissionId: "t06",
                                     createdAt: createAtBaseLine.addingTimeInterval(-6 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a06"))
            // submission status returned by server: finalized reject. NB: submission status causes this to be deleted
            realm.add(TransferEntity(amount: "7000", submissionId: "t07",
                                     createdAt: createAtBaseLine.addingTimeInterval(-7 * minute),
                                     transactionStatus: .received, outcome: .success, toAddress: "address-a07"))
            realm.add(RecipientEntity(name: "Carl1", address: "address-a01"))
            realm.add(RecipientEntity(name: "Sara", address: "address-a02"))
            realm.add(RecipientEntity(name: "Mohamed", address: "address-a03"))
            realm.add(RecipientEntity(name: "Salma", address: "address-a04"))
            realm.add(RecipientEntity(name: "Heba", address: "address-a05"))
            realm.add(RecipientEntity(name: "Hoda", address: "address-a06"))
            //swiftlint:enable force_try
            MockedData().showToast(withMessage: "mock data added. Number of accounts: \(realm.objects(AccountEntity.self).count)")
        }
    }

    private static func createIdentity() -> IdentityEntity {
        let identity = IdentityEntity()
        let identityProviderEntity = IdentityProviderEntity()
        identity.identityProviderEntity = identityProviderEntity
        identityProviderEntity.icon = encodedImage()
        //swiftlint:disable line_length
        identityProviderEntity.ipInfoJson = """
{"ipIdentity":0,"ipDescription":{"name":"Notabene","url":"","description":"Notabene identity provider"},"ipVerifyKey":"97f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb93e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb80000001ea7548ffd433d367a97faee70cc984d0fe70c42a55a250f932931f2fade1ad646db4fc165e945fd320ce59d1caec8b131b1fd879bd43bfb3c024c27e5913abacb281412b872be11dcf1dfaf08406df8516d8f5d6991f0696613d7c1644faf292280b3b3baa1a8d79928c144421e823772d60881b3877f10d303df45171e29e26f351c117944717c3f165391ef59827d1584716c97e785650697b7c393569259af53c59f90d3b342e7132ec8fc716a6be6732f43a0b2174a9033077c890da94394ad51f06a02b9d353c7a75b1100594f7173e21a7bf9dd25620a54836a17ae5dbd1b34a5ba809dce0fc7150d414b0f8eb299ca528b0e93686927dceaeb860888840dce9403665b36ac455b7557166bdf6a511ba22cb694d03d203454b475d0dbf2ab7e05f77924392a4e23950f3fab998e5ea05f85e91cdd500353bec202e9e478a705df7e222dfc36b7ce4719ac261a8ba4cf33dfbb90e0d2afc68037d61ddb7c1c7b04a629f07536d06aacb936bed1e419bd50470b16855076f56d1fb8c67227a5d28cd8b8b36d245c3676385b0eb84c148600f8ae2cdf291c831b691a4b474fe114239af295a1967e23781722ede363ad88976011ee9805516a58cfc068ad48ac6423cd6145cfa497e70379d2838231382f2cca7a9fffc03ccb50b011179a138bbe227457a8da0f851978028c67cf66a124885d4cab258a0bcd7230b92ef0e8de295f2d2b53fdfafa451ab7fe0581648c2c31f10a6d248820f502790f93f6528bee56434f6051963c2c25a609acb194f3f4330f45a45aaec3964f50352a69f18111e89da03feb89ccd9549167cb59686b9bfe4d009e36ff213d0480826210a663646644a45e572e6ec89b4e154f7f6aac29f145a3062a383fc0c3f5486ab70ebef8f4c7dbea60d506cb65312236447226820e36fe3ff66d24575a0a9dc11cecb92c1ca1ec695a6dcd96fb3d48299e05d261e5dc9ac40a382a55cd484223a91b4c6583ba892eed4fa2bf55576e93deb8917c92f6e7721d71b313b5d08ecd8922a0bc3cc8e075297076310b8abbd58122230e1ab59a8db7c5d02157ce7d321768b9ab3832b14b3210c8de981d359ef8299147cff3bf9f80271a1410d4810cd550f73d8fd048f7ef799dcc8a4e3b3016888c1a3991c49d93625bb27d4395488035b4eb58f559a971d41ebea7a41677c14cbee66cc9f8903753e9e64bdf2cf5492c90e4c8180c92ad72fe1c33313a0650ccf9d838cce0609db850bf52ecd2e95fea1d39acf3efd5468674ba56a015bef15d8a938957b5e914458c9ccf35d393cbb4bf792b7c4e44d9ea58e0076f2d65d58c32b4a94e13017efeac853a81c6925bb4b77173a2757c241365ac208aeb5da6d6f85789a26ca471039864fc7ae829df04ee66d1b8cadc4c1b21115a73853d4c77963573aef2a5b4c7e6ddea618e6f0432261390933e9706297bf44eaf55a12c9cb53de9041f5b6aabc3674234b92ff95cb9a2f102c9108ea0507a6222eff7d68360fcd9595898e09cc257163d88c8abb5de45e61715158127db1ee4c3d3ba5a34b189d63c4bbe4076c82cbb6ea9cf2e5f05ba463e9aa42ae4c8fdc7f3ffcce31e6908a806105f56415c66dda82827e6fb99dfd9e3d90177bc9fe172abd23d1bf1bb02f40b04148ae8509414c2c968dfbdc357c84839c7d9909f82494aad5b5470b37f91d38a0b4b069bd6e9991c2b25ecb79fc1dd576f50f7c40365a20bfb93e76e88cab4ee59adc7801ea07118cd1a5893a072a24a750b431686d57b0e1e9814dfe6a2ec5b8c64a7112fc8ac339291386df23a39f0ceefbb7816575e38cbb5b497aaeddc03743dd3c0273aab3a7a356dbae02602bcd216389233fd9495a48da070a498e9a3594c8a4c6a81c5eabe3dedac7213a3b26cdabfe85f588e45e2aa0468ab7d09de477730f2b2504d889d540312b42554fe65279d16cbac4bee8ab4f3a0260f4983a56b6f253df232b4bb8d4c8a0e2e11766675014761d5fa31fe2e1955380f9a378c5da1b661eb5b845d633f0000001eab535a6f58f4563046121dabdf062c9b148fabf0d2206b4e03dc06eb7df71ca5acaa2227f838ee9f5cf619ca55d77544094dd23435efc748a7be187eba51c30c07063c3fc660b5c15a270a83c672817b218f99536bde2e3de286f4b46b883b248872bb330c07eef406c0969b8140ffb78a7565d957086c4098dc6be20a4c820cce249f4fe923f87d1b15e5318c79180a1974542b33d3363d6b186eabca9981054268ff0e24b1856bab2138f7903b3f45351dab25eb0e1808b2199fdcf2cfa58c83f5ede37a8e59b77d67da6694cdb418973c37df22124d2ed37e7354d9ba9ae3354a9798e5a0b92c174fbd4e2e98a2510cef377e60871ca0ac5b9cfde66177c8d38c0ecfada156fb755e809c21de05306da0621cf1ed4e02fc31b71b194dc38f998d73f79e2487880b79f80aae792568010e08257e83a99153a9e36ae50a434677b282562ae34bac0fc28379ff73e336018213decabf6e8181887fbeeeaaa9d939c92e3a4f50a382175c658ece5fb26154a202130ce414dea2401a8d9015e3fdae045b53b8e5529fd9aad8a7025010f6b6d1d35591e46dffe8e4a7e8cacc6733419a1eb1b47969e5fe3aa36ad76f3abe144fa542e140aebe4cb90d4d823c94b547cc832cca71cd25671b98984f4b6d1ae3750599b5948832bf01a0177ebe5087b8aabc0a1781cf6c02414c2eb96fc0f420227deb9cbf94db1059f97ea8d08c448adaa60b861cc43f05ab681fb0856f2306dc767693d1b9fea181164eabd6d60e31ec10beb020cfa99fda24f1fb0e2d5185abeee0b0fdebe961f974193f3e3260ad7b61fe1f31ca47f0c84d66ff36fc45cad546b6d7b856991643b81c1e63a0df230dead2ff775d2ac6e60964dacba36f131ff7ee9ef5b5fe16607f53ffd3038313db8764b33ae867ace6d4854691d512812cd82c001ed7aad04bcceb3b8c990a8aebb63b98cb7c3e70cba18b3d4cbeb3c8dd53179eb58c737c1e46a09b3dba6426605b5e87b54d768373af86cb693eab13bb284363a1373c655f887dce4ebdf0e83b7cb816f7f6d88f045849e2f835d453f771e79a4c5c2ace51fe27bec26387ac781ce2d8ddb513f44f0b6c63d853cbd2c13536127285b6c8e92561d3f30af649ccf852d522271f221a358b291689a40aba0eac530dfccdd6152542061e40830b29009b3ff22ff47a10681c3fe7fc526df301590bb1091d36d1baf5d519e5f4af6dae62b410a862ce7e38d1676113c4e8493f3bbf15275166e985068132a39b9a9806bc9cb6a04768027a7ef186edd001ca62b00de5c3391696d7acb3525e5946f863ec43733160aad1dbefbf2215a60a8d35482c52a60273569a8a3f01f1f0af81b28839abd7719a3c748778891911aac29128c5f01ddf841e4db899ca8ba74782aa1bc1977bfb07962cc5b1b1c70109a9eb01da5f5e99e0865408c5721f3d0c5982e1e756cb15ea13858e6f14ff7651ba308bbd274c2c29be06e76b5cc08ca04717e7116795431dbbb32d05f11f373055f75cdb1c9180347ecea8925755d0aab471298ee2125f28afd41c1dcd7285093aea3355d42879098fce61df12ea8fdf57668e2ea24dd0592d7151aa37c9b783bb1905e2a1f55b323e8f4f937090e8b9df523c077e1f3387bfe29045b3ac3c0268449ed9456fad5fbc151f5a52e6ad4a8da0e3ca8d6924532a471921d32c4f18d98170816ebe551bab2e80f80a5c7974c247ab4af9827f1a0b702076ffb28929e1b65a7e420066c782a5d67868797985409feb46931c1a2fc7977c0c62af84dd7558f157b181bd946bf4c84251590b88832ca1edf373c9b8dc9df5a54a1b15120a6b4be55d11f51dacfaf4c8c7670a97eb77c93c11e0ee142216b1c83e7e19438f8314b44d95fafe42ccb590f0b84da38c9c09b2c64f619529dbf4cff204bafc9473cd8b365d52bd96b639da6815151c60e640e6a6034601dd8f757cdaad7f0afe136372e93b548161d5aa5729335352aefa54626e8f4f0b0083fc70e2fc437209cab59acf9d8e19fcae39de376fa98ce962dbf7653759671625e8b7ab6d97c14d6e445e5bbb3dcc174ed23b8daa145be04ace90dde3e8484fdfd92669692d19b997f74a3b54364bb7368e3f9648ee4eb6f0196753bb7b59b4d0b2b4ed92b67c781d63169c652a3a2add7277a0f6e989149ed6dc0f7957381890ceff256bbe68b127e567f4032831ddaf418d1ba7f3c166b1f953fb533306b216b01ea3959d048cfdcb013f4c97c123344bebbe3696365b58b829371792418582c00c97ecb703760b60adc46da059cd75ae89ae6f14afe822c237cac9895cacc4fae3b14267ea6ff716ac87692538a1f44f2108f321c02c84aabc07e9e55d0c2da9908beeac1590a879672613290cd81df8fd2b4c71d503a5e2572896356e9180132c565f2cc97456f59eab0b9421b864e26956e703b9004fc8157ad317f49bb3ebb1260c59ac28918b07810c0530b2b251f7631a4bdae74e3a9cc5c7fe96a1cc4a87be8b2f075ca1e3ccd686a39f7befea09a251cecf73dc8fa791778b3bdba5f15b89150c456c2124992fba27c5e6557420492a1a84b2d923f84c05e082d5ff8a2d39bbb02a5ed2e5724207504a60f8a8837aa2f036b259ab951c34b6e17f736e04fbf4ce110367009a002418a227f464ed8c95eed4af8757b3244eec3b06255e29b120be577f7554a505fb943ccbd00cd6c20c52ab98e8cf87b84b076053ed0c7e4ec000ca3f220b545fb093cebc51a39a3826ef18e199052321e79e1552c628aa3a11651130ab144f0d9d4647b3fed3ae1aee39f84c4eebd4f46be3cf32adabab41e7fecdfb31b23e38ed982f772812bb02651c98a449c5aef9ad8673030de966acb70d2fbe71e96ebeea7d20228da24f021da5b9f0de55cf49972811c0832c69443d640d8689e50a228725e1a05378ddfe3dc3faf8844af32c0017040c24d9517242ccf4e948520bc711707e5ba03b9d4bab23865a7b147172ab935bc97a0b6b3275be18615e99e9bc8216f4f9b4a30c4d85a02575e0011cd26dc3b903cf9c0923e95202ccc0dcd4d160f9e5f9ff770d82d802fea3dfc8fd1eb8efbdd61643e5119cc9f7f1c59cc3ac748d0f0d8e9421378105890fe4650956383befbcac0d626710e793ced80b8ad24b208d384e965b90c92167b80fadc490e265609b609f321009c90373f5db9081ca853fa36af27d1783e2e2b4052c20dd1275a9b3dbfb7bcff86fa915913e8c465485c12b012c7d05719f8ccfe15fbee0990f0771970f979ff66a978214ce15503ac8cb2fde7042c1d7998cf106c6cbe37e1aa40cbb184c313b351991d02d6505cc1753fbc39ae3c5f0ea7257a38979320a07d7ad8f75e984b55bfd1b63bd77c08f33ea446142b090212cb24159b5c623fe0c6ce1ddd6309977bfd1167b7e0b067ba6445c6c5715bd8d4ae32f934e43fae0f5e4cb35b8b840434d10f21d92a47ab47e117d6a556a3e2ee365bf2c8f2e118525682438728e7cb940c4faeb416351b7865a16f57f54ee6eb6b13e2a0e2ab19b8de23454f0501d92fb211ec32fbd4a682441f61b27025b2b55d740b31105addf0082c8197d8dd9142c1144212b027e23afada0f9cd825cd493a479fe58de5ec4371f1f16ecc3f4eab1bb48a09a64c47fe0340436c53bf5e95d93e8c724903ae51d3790176a66dfd2337d7c7aea827cf1641916603a40a254c05b6537d8a8264cd5e515134644c0eb9b0783b0850e297b63b8eacb9cc1f36cf25d80ad04585864b621bcfabdec91b84303d3d01c3116a65610dde5c2349babffafbe77ed150ca87057c20c19bb870fd44430d5c091399746ea06adeed88e170c38a4fdd7261995672fc5b7e2a1aca58706e3999636599ab836c8fe0541c8c504165c337aec3bdeb9cb49d874c04aa7697352317fe835da52929fbe9b6e70c7d0862f92d92c16b6a296634052f803f6780a738c61be21a7e1f5c0e27b2d9e853856875f65446e911afc16071aa4f9710a1361a44d89d8af9d0fa5034f06ff9bcd65c47b57b5c0e3b3dcc40a62a6af6818e5ab217ae2a3b7ade6199e5707fce98f875762655574724cc5bc512ea030918bad456ec4181aa78567a7e42cd5e303d399ea1d26e5003595b345826e49320b9711c1b89471a2295a9c67758b23c89ca70757696df182fd5d21c7a919654ce089b6b6984ff0393c38096d703b069d3d40","ipAnonymityRevokers":{"anonymityRevokers":[{"arDescription":{"name":"anonymity_revoker-0","url":"","description":""},"arPublicKey":"a98a90310f98c0704476514316c2473856dc946d40fb8a6bfd249432fe4a61d363ce5cd238118eff53453729c4b2528ca7943758856ab46ede42574da54e9a7987b379460bf6ac4be9f82ff193863e5e052fb09be1d6577d435e4838ece4d753","arIdentity":0},{"arDescription":{"name":"anonymity_revoker-1","url":"","description":""},"arPublicKey":"a98a90310f98c0704476514316c2473856dc946d40fb8a6bfd249432fe4a61d363ce5cd238118eff53453729c4b2528cb1ed154eb693195eb616d9b15bf63d57a9f9b72538c49c04e7700aacee33b9e74a3fba181396ce3b91067a5213b89dfb","arIdentity":1},{"arDescription":{"name":"anonymity_revoker-2","url":"","description":""},"arPublicKey":"a98a90310f98c0704476514316c2473856dc946d40fb8a6bfd249432fe4a61d363ce5cd238118eff53453729c4b2528cb35689d7c6d1e4d87ec3772227751ceb5269543a8010525da5c31e06d1c5b7613fd5a2683be56b66ffb0dd3aa23f8f9f","arIdentity":2}],"arBase":"a98a90310f98c0704476514316c2473856dc946d40fb8a6bfd249432fe4a61d363ce5cd238118eff53453729c4b2528c","arCommitmentKey":"906b380520f70f2940ab0ecd1b086a4bed3723b4c481ca66800f14cc300790b1c75f0972f2f198f72581283f7c96853b88fa419b2f25a1570d2762af7dc70f35bae1a1b677262569c8330449e0621838cf9ff4c690f5d8592ce26457488069b4"}}
"""
        identity.identityObjectJson = """
{"preIdentityObject":{"choiceArData":{"arIdentities":[0,1,2],"threshold":2},"proofCommitmentsToIdCredSecSame":"3be1e26e08a99312a345652f9997876f56ab5716dd7c0251f55f5844aa324a9e000000014309b4bb3f219a94437ba8f8428efb92f5e70bb5215d12149fbe177195760bed162c71194e779a9d5651e7ea001ca9c9cb8b810443dab32dfbe86de12c2938e7","prfKeySharingCoeffCommitments":["95318e1f78513d17a56a92910b662c5c43cb1867354ec151ecc1a24754e03de3f9731b514adb3dfe440ed44187cd9884","ab36be3ad14ba885972dcb779ccdfcc6c96b023f968832c9d487921d792911d3d64e7ea34bde66d29b9ee374ca23a17a"],"ipArData":[{"encPrfKeyShare":"ad107167848ec0e1cc12dbc249b5eb72b4df21dd7db2cc4a67d452450b3593a6db12edd138403d92488061989dab5e2198b6839a8a2365a70d2974d51b60b831c64c5f1733a65f818c07738d342aff498aaca281e6aa788b68d68472bcb90e4d","proofComEncEq":"1daf0cdc98203254848da37ca0bd24685dda7bf91bf2153b6348bda9c576e93d5ca5b3d0be048c0ad16f0465ce0be3343811052cce42b1993535b24f80b7c5763b3ce6eb89bff65009fa3401d930c089d72124d2b848d9d1164a1ab7fee8b927080218daec6c38eed50032967f607db14b7094028d8d0b4ebf31d14ceeb6d117","prfKeyShareNumber":1,"arIdentity":0},{"encPrfKeyShare":"a477a58ff84b450953607f46c1585887aed3d5a7bd7485473e120ffb5c0848b28bde626bed56f7999f16ec4701319833b483ea7a81939e7d0481f08d7272a86086dd528dd90deb5ad861cedc6239b79c997d12396f6a7dc3a76dfa2aca804deb","proofComEncEq":"6b239b7f30c1127d58606c7cc90cf8ed7c63734f539d60a8e87f7ecbc470956c474ec19db88736d16b95e1de0b7d23999daf2faac22b736309038ee1eac2129d0fb4951a84079438675789d19237a0ad451f9b20c48f931b7d309d51d85b0f145aaef3e74fb6cbcc3d7c6e929a4d401db480c0d807a43e12508321f3456016a1","prfKeyShareNumber":2,"arIdentity":1},{"encPrfKeyShare":"b5399dad995cabbd84cad4a9ac8574570fd02925359c54f0be08d3038d826fa65268ecc39d06f4cb77b7b815ab25a1cbb03228977e075040b89539ec5119565b33c552346a93d7e4f70f82fefdcf4045ff2c2be5cda11a27850bbeefb881206e","proofComEncEq":"57f5f4545bceee47fbe47fb83a7e472605bab3bbe654da6a205d95958a50604f018362fbf2c60ca9a85442b4564a67d59e55dd646e0471c16d26795aaacb1c4f09f07e7e913324a8c38c757ca7a5dd45e1fde6d9583ee54d246ca0adb82fea8e2602e988e4b86b7261bc87d622f3ebc44e98a5a5ce758cd3fdd17eb1e3a01244","prfKeyShareNumber":3,"arIdentity":2}],"prfKeyCommitmentWithIP":"b3852f60f8dd65f7db555edfe37bc2568fbfb4f1663db628d60c8c19e9c9a8f41d65bd8ee0d0b57b8418bee3e13ac5f8","idCredSecCommitment":"acdd932ac273fabca8c52bbad0734952b2f24b264da262549230297aeaa9a387c10ea3c1e1ef4888a9804c55a6fff9b0","idCredPub":"8847b34f93028a175dc856e9db406d1f794acd9f0aaa5ebcbdbd6a80734eecd43ffb3d8bcb49d79f907501f31a96dc09","pokSecCred":"4f9abb6a631a160da9d5da778fba7af0be0bd1453841d2ff2fbd921b74b349f91ff728fd3d7e3d72642f5e9d1b0e33c60cf9db3135c521b20917dbf84c79953e","proofCommitmentsSame":"4fcfab0531ccabb3ab56dc49789d977177af3816c3e09be9ac7d39fe546aca5a4db7193e99f90da86d9443f2ca7ad988e93de4ce24df2124b2b24184dca2d5932b7ca3ed9356b735cf7487594482cee0308963fe63304ff1231871eef0c36be129f60e9b1ee72cb3df65098b629b74389eb252a0613b4d54d02406b1d8c60c96"},"signature":"862627c2b6a0a5ba6056bd70957a8405fe2a4b401a4c9df283290dc1704622aab79b7fb1c2b4e4205a6cf9906500cea38b068852e6f4508b40974fb21b1618b652b52f8c37994c0619fb26731c9b20f081beff5bb2477ff959e4f56c06dc4e1c","attributeList":{"createdAt":"202005","validTo":"202105","chosenAttributes":{"idDocNo":"1234567890","nationality":"DK","firstName":"John","idDocType":"1","countryOfResidence":"DE","idDocIssuedAt":"20200401","dob":"19800229","sex":"1","lastName":"Doe","nationalIdNo":"DK123456789","idDocIssuer":"DK","taxIdNo":"DE987654321","idDocExpiresAt":"20291231"},"maxAccounts":238}}
"""
        return identity
    }
}

extension AccountEntity {
    convenience init(name: String, submissionId: String, transactionStatus: SubmissionStatusEnum?, identity: IdentityEntity) {
        self.init()
        self.name = name
        self.address = "address-\(submissionId)"
        self.submissionId = submissionId
        self.transactionStatus = transactionStatus
        self.identityEntity = identity
    }
}

extension TransferEntity {
    convenience init(amount: String, submissionId: String, createdAt: Date, transactionStatus: SubmissionStatusEnum, outcome: OutcomeEnum, toAddress: String) {
        self.init()
        self.createdAt = createdAt
        self.amount = amount
        self.fromAddress = "address-a01"
        self.toAddress = toAddress
        self.cost = "59"
        self.submissionId = submissionId
        self.transactionStatus = transactionStatus
        self.outcome = outcome
    }
}
