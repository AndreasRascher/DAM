/*
Belegtransfer
=============
Einkauf, Verkauf, Produktion

Verkauf
	Tabellen     
		Sales Header
 			Sales Line
				Reservation Entry (Item Tracking)
				Sales Charge Assignment
	Optionen Allgemein
		Löschen
		Updaten
	Optionen je Tabelle
 		View
	Optionen je Feld
		Reihenfolge
		Ersetzen
		Weglassen

Objects
- Table Document Dataitem
  - Line No.
  - Type: Document Structur, Document Table
  - Indentation
  - Table No.
  #region Processing Options
  - ExistingRecords: Delete Existing Document before import / Replace existing Records / Modify Existing Records
  #endregion Processing Options
  #region Dataitemdetails
  - Default Filter
  - Table Caption
  - Table View
  #endregion Dataitemdetails
  #region TableLink
  - Parent Dataitem
  - to Field
  - Link Type (Field,Filter,Const)
  - From Field
  - From Filter
  - From Const
  #endregion TableLink



-------------------------------
1. Delete Old
        if SalesLine.get(SalesLineOld."Document Type", SalesLineOld."Document No.", SalesLineOld."Line No.") then
            SalesLine.Delete();
        Clear(SalesLine);
1. Migrations init
// Type - Validate -> Resets Sell-ti Customer No.
        WhseSourceLineExits := WhseValidateSourceLine.WhseLinesExist(DATABASE::"Sales Line", Salesline."Document Type".AsInteger(), Salesline."Document No.", Salesline."Line No.", 0, Salesline.Quantity);
        if WhseSourceLineExits then
            Salesline."Shipment Date" := SalesLineOld."Shipment Date"
        else
            Salesline.Validate("Shipment Date", SalesLineOld."Shipment Date");
        if WhseSourceLineExits then
            Salesline."Quantity" := GetLineQuantity(SalesLineOld)
        else
            Salesline.Validate("Quantity", GetLineQuantity(SalesLineOld));
        // Salesline."Outstanding Quantity" := T37Buffer."Outstanding Quantity";
        // Salesline."Qty. to Invoice" := T37Buffer."Qty. to Invoice";
        // Salesline."Qty. to Ship" := T37Buffer."Qty. to Ship";
        Salesline.Validate("Dimension Set ID", SalesLineOld."Dimension Set ID"); // Verschoben vor Globale Dimensionen        
        if DimValueExists(SalesLineOld, 1, SalesLineOld."Shortcut Dimension 1 Code") then
            Salesline.Validate("Shortcut Dimension 1 Code", SalesLineOld."Shortcut Dimension 1 Code");
        // Salesline.Validate("Recalculate Invoice Disc.", T37Buffer."");
        // Salesline.Validate("Outstanding Amount", T37Buffer."Outstanding Amount");
        // Salesline.Validate("Qty. Shipped Not Invoiced", T37Buffer."Qty. Shipped Not Invoiced");
        // Salesline.Validate("Shipped Not Invoiced", T37Buffer."Shipped Not Invoiced");
        // Salesline.Validate("Quantity Shipped", T37Buffer."Quantity Shipped");
        // Salesline.Validate("Quantity Invoiced", T37Buffer."Quantity Invoiced");
        // Salesline.Validate("Outstanding Amount (LCY)", T37Buffer."Outstanding Amount (LCY)");
        // Salesline.Validate("Shipped Not Invoiced (LCY)", SalesLineOld."Shipped Not Invoiced (LCY)");
        // Salesline.Validate("Shipped Not Inv. (LCY) No VAT", T37Buffer."");

*/