//
//  FreeAnalyticsKeys.swift
//  Mon Compte Free
//
//  Created by Free on 16/10/2024.
//

import Foundation

extension FreeAnalyticsManager {
    
    // MARK: - Event
    
    enum EventKey: String {
        
        case passwordRecovery       = "password_recovery"
        case disconnection           = "deconnexion"
        
        case billWidget             = "bill_widget"
        case billExplanation        = "bill_explanation"
        case billLastInvoice        = "bill_last_invoice"
        case billOldInvoice         = "bill_old_invoice"
        case billPayment            = "bill_payment"
        case billPaymentCard        = "bill_payment_card"
        case billPaymentEficash     = "bill_payment_eficash"
        
        case wifiWidget             = "wifi_widget"
        case wifiShowSSID           = "wifi_show_ssid"
        
        case smartTvCard            = "smarttv_card"
        case smartTvShowProduct     = "smarttv_show_product"
        case smartTvSelectProduct   = "smarttv_select_product"
        case smartTvValidProduct    = "smarttv_valid_product"
        case smartTvNoHardEligible  = "smarttv_no_hard_eligibility"
        
        case freeproxiXdiag         = "freeproxi_xdiag"
        case freeproxiSendMsg       = "freeproxi_send_msg"
        case freeproxiQuestions     = "freeproxi_questions"
        
        case assistanceHelp         = "assistance_help"
        case assistanceCall         = "assistance_call"
        case fbxThot                = "thot"
        
        case settingPassword        = "setting_change_pwd"
        case settingBillingReceiptPaper = "setting_change_billing_paper"
        case settingBillingReceiptMail  = "setting_change_billing_email"
        case settingBillingReceiptNone  = "setting_change_billing_none"
        case settingPhone           = "setting_change_phone"
        case settingMail            = "setting_change_mail"
        case settingIban            = "setting_change_iban"
        case settingPasswordRecovery = "setting_password_recovery"
        case settingsThemeAuto      = "setting_theme_auto"
        case settingsThemeDark      = "setting_theme_dark"
        case settingsThemeLight     = "setting_theme_light"
        
        case rankingFailure         = "ranking_failure"
        case rankingStore           = "ranking_store"
        case contactUs              = "nous_contacter"
        
        case satcliUnifie           = "satcli_unifie"
        case satcliClassic          = "satcli_classic"
        
        case mobileDiscount         = "avantage_mobile"
        
        case equipmentShop          = "boutique"
        case cancelEquipmentOrder   = "boutique_annuler_commande"
        
        case orderRepeater          = "commande_repeteur"
        case simulateRepeater       = "simulation_repeteur"
        
        case swapOrageStart         = "swap_orage_start"
        case swapOrageConfirmation  = "swap_orage_confirmation"
        
        case optionTV               = "optiontv"
        case optionTVCodes          = "optiontv_codes"
        case optionTVSubs           = "optiontv_abonnementtv"
        case optionTVMultiTV        = "optiontv_multitv"
        case optionTVChangeCode     = "optiontv_codes_change"
        
        case movingOut              = "demenagement"
        
        case homeResiliate          = "home_resili"
        
        case portalNewsArticle      = "portail_article"
        case portalNewsShowMore     = "portail_plus"
        
        case voiceMail              = "telephonie_messagerie"
        case voiceMailCallBack      = "messagerie_rappel"
        case voiceMailDelete        = "messagerie_supprimer"
        case voiceMailDownload      = "messagerie_telecharger"
        case voiceMailPlay          = "messagerie_lecture"
        
        case freeStores             = "boutiquefree"
        case freeStoresItinerary    = "boutiquefree_itineraire"
        
        case mobConsSwitchNational    = "m_fr_switch"
        case mobConsSwitchRoaming     = "m_etranger_switch"
        case mobConsSwitchLine        = "m_ls_switch"
        case mobConsSpecSheet         = "m_brochure"

        case switchToFreebox = "switch_fixe"
        case switchToMobile = "switch_mobile"
        case mobPhonePlanCard = "m_detail_forfait"
        case mobInvoiceCard = "m_facture"
        case mobConsumptionCard = "m_conso"
        case mobTabbarHome = "m_accueil"
        case mobTabbarAccount = "m_compte"
        case mobTabbarSettings = "m_reglages"
        case mobThemeSelector = "m_theme"
        case mobRating = "m_rating"
        case mobAboutApp = "m_apropos"
        case mobDisconnect = "m_deconnexion"

        case hubFreebox             = "ea_fixe"
        case hubMobile              = "ea_mobile"
        
        case mobLogin               = "m_login"
        case mobHelpLogin           = "m_aide"
        case mobForgotPassword      = "m_mdp_oublie"
        case mobGetId               = "m_id_oublie"
        case mobNewPassword         = "m_nouveaumdp"
        case mobOTPSMS              = "m_otp_sms"
        case mobOTPEmail            = "m_otp_email"
        case mobValidateOTP         = "m_valider_otp"
        case mobTrustDevice         = "m_trust-device"
        case mobOnboarding          = "m_onboarding"

        case mobAccountLineManagment = "m_gerer_lignes"
        case mobAccountUserInfo = "m_info_perso"
        case mobAccountOffer = "m_offre"
        case mobAccountCA = "m_conditions"
        case mobAccountFreeboxAdvantages = "m_avantage_4P"
        case mobAccountSelfcare = "m_assistance"
        case mobUserInfoModify = "m_info_modifier"
        case mobAccountMobileOrder = "m_mes_mobiles"

        case mobSummariesCard = "m_recap"
        case mobSummariesPDF = "m_recap_telecharger"
        case mobInvoiceUnpaid = "m_facture_impaye"
        case mobinvoicePaiement = "m_facture_regulariser"
        case mobInvoicePDF = "m_facture_telecharger"
        case mobUnpaidStatusPaiement = "m_facture_home_regulariser"
        
        // Biometric
        case mobGrantedBiometricAlert = "m_biometrie_premier"
        case mobGrantedBiometricSetting = "m_biometrie_activation"
        case mobLogWithBiometricSucess = "m_biometrie_connexion"
        case mobLogWithBiometricFail = "m_biometrie_ko"
        
        case fbxGrantedBiometricAlert = "biometrie_premier"
        case fbxGrantedBiometricSetting = "biometrie_activation"
        case fbxLogWithBiometricSucess = "biometrie_connexion"
        case fbxLogWithBiometricFail = "biometrie_ko"
        
        // Sim / Esim
        case mobSimShowPurchaseOrder = "m_sim_state"
        case mobSimActiveSim = "m_sim_activation"
        case mobSimActivation = "m_sim_activer"
        case mobSimActivationGiveUpWithDrawal = "m_sim_activer_retraction"
        
        // Roaming
        case mobRoamingCard = "m_roaming_pays"
        case mobRoamingRow = "m_voyage"
        case mobRoamingSearch = "m_voyage_pays"
    }
    
    // MARK: - Action

    enum Action: String {
        case event = "_event"
        case click = "_click"
        case none = ""
    }
    
    // MARK: - FreeBox

    enum Box: String {
        case pop = "a"
        case deltaPop = "b1"
        case deltaApple = "b2"
        case deltaDevialet = "b3"
        case deltaS = "b4"
        case one = "c"
        case mini = "d"
        case revolution = "e"
        case crystal = "f"
        case boxHd = "g"
        case undefined = "undefined"
        case ultraPop = "h1"
        case ultra = "h2"
        case ultraApple = "h3"
    }
}
