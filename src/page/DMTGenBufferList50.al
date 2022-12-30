page 110002 DMTGenBufferList50
{
    Caption = 'DMT GenBufferList';
    PageType = List;
    SourceTable = DMTGenBuffTable;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.") { ApplicationArea = All; }
                field("Import from Filename"; Rec."Import from Filename") { ApplicationArea = All; }
                field(F001; Rec.Fld001) { ApplicationArea = All; Visible = Fld001Visible; Editable = Fld001Editable; }
                field(F002; Rec.Fld002) { ApplicationArea = All; Visible = Fld002Visible; Editable = Fld002Editable; }
                field(F003; Rec.Fld003) { ApplicationArea = All; Visible = Fld003Visible; Editable = Fld003Editable; }
                field(F004; Rec.Fld004) { ApplicationArea = All; Visible = Fld004Visible; Editable = Fld004Editable; }
                field(F005; Rec.Fld005) { ApplicationArea = All; Visible = Fld005Visible; Editable = Fld005Editable; }
                field(F006; Rec.Fld006) { ApplicationArea = All; Visible = Fld006Visible; Editable = Fld006Editable; }
                field(F007; Rec.Fld007) { ApplicationArea = All; Visible = Fld007Visible; Editable = Fld007Editable; }
                field(F008; Rec.Fld008) { ApplicationArea = All; Visible = Fld008Visible; Editable = Fld008Editable; }
                field(F009; Rec.Fld009) { ApplicationArea = All; Visible = Fld009Visible; Editable = Fld009Editable; }
                field(F010; Rec.Fld010) { ApplicationArea = All; Visible = Fld010Visible; Editable = Fld010Editable; }
                field(F011; Rec.Fld011) { ApplicationArea = All; Visible = Fld011Visible; Editable = Fld011Editable; }
                field(F012; Rec.Fld012) { ApplicationArea = All; Visible = Fld012Visible; Editable = Fld012Editable; }
                field(F013; Rec.Fld013) { ApplicationArea = All; Visible = Fld013Visible; Editable = Fld013Editable; }
                field(F014; Rec.Fld014) { ApplicationArea = All; Visible = Fld014Visible; Editable = Fld014Editable; }
                field(F015; Rec.Fld015) { ApplicationArea = All; Visible = Fld015Visible; Editable = Fld015Editable; }
                field(F016; Rec.Fld016) { ApplicationArea = All; Visible = Fld016Visible; Editable = Fld016Editable; }
                field(F017; Rec.Fld017) { ApplicationArea = All; Visible = Fld017Visible; Editable = Fld017Editable; }
                field(F018; Rec.Fld018) { ApplicationArea = All; Visible = Fld018Visible; Editable = Fld018Editable; }
                field(F019; Rec.Fld019) { ApplicationArea = All; Visible = Fld019Visible; Editable = Fld019Editable; }
                field(F020; Rec.Fld020) { ApplicationArea = All; Visible = Fld020Visible; Editable = Fld020Editable; }
                field(F021; Rec.Fld021) { ApplicationArea = All; Visible = Fld021Visible; Editable = Fld021Editable; }
                field(F022; Rec.Fld022) { ApplicationArea = All; Visible = Fld022Visible; Editable = Fld022Editable; }
                field(F023; Rec.Fld023) { ApplicationArea = All; Visible = Fld023Visible; Editable = Fld023Editable; }
                field(F024; Rec.Fld024) { ApplicationArea = All; Visible = Fld024Visible; Editable = Fld024Editable; }
                field(F025; Rec.Fld025) { ApplicationArea = All; Visible = Fld025Visible; Editable = Fld025Editable; }
                field(F026; Rec.Fld026) { ApplicationArea = All; Visible = Fld026Visible; Editable = Fld026Editable; }
                field(F027; Rec.Fld027) { ApplicationArea = All; Visible = Fld027Visible; Editable = Fld027Editable; }
                field(F028; Rec.Fld028) { ApplicationArea = All; Visible = Fld028Visible; Editable = Fld028Editable; }
                field(F029; Rec.Fld029) { ApplicationArea = All; Visible = Fld029Visible; Editable = Fld029Editable; }
                field(F030; Rec.Fld030) { ApplicationArea = All; Visible = Fld030Visible; Editable = Fld030Editable; }
                field(F031; Rec.Fld031) { ApplicationArea = All; Visible = Fld031Visible; Editable = Fld031Editable; }
                field(F032; Rec.Fld032) { ApplicationArea = All; Visible = Fld032Visible; Editable = Fld032Editable; }
                field(F033; Rec.Fld033) { ApplicationArea = All; Visible = Fld033Visible; Editable = Fld033Editable; }
                field(F034; Rec.Fld034) { ApplicationArea = All; Visible = Fld034Visible; Editable = Fld034Editable; }
                field(F035; Rec.Fld035) { ApplicationArea = All; Visible = Fld035Visible; Editable = Fld035Editable; }
                field(F036; Rec.Fld036) { ApplicationArea = All; Visible = Fld036Visible; Editable = Fld036Editable; }
                field(F037; Rec.Fld037) { ApplicationArea = All; Visible = Fld037Visible; Editable = Fld037Editable; }
                field(F038; Rec.Fld038) { ApplicationArea = All; Visible = Fld038Visible; Editable = Fld038Editable; }
                field(F039; Rec.Fld039) { ApplicationArea = All; Visible = Fld039Visible; Editable = Fld039Editable; }
                field(F040; Rec.Fld040) { ApplicationArea = All; Visible = Fld040Visible; Editable = Fld040Editable; }
                field(F041; Rec.Fld041) { ApplicationArea = All; Visible = Fld041Visible; Editable = Fld041Editable; }
                field(F042; Rec.Fld042) { ApplicationArea = All; Visible = Fld042Visible; Editable = Fld042Editable; }
                field(F043; Rec.Fld043) { ApplicationArea = All; Visible = Fld043Visible; Editable = Fld043Editable; }
                field(F044; Rec.Fld044) { ApplicationArea = All; Visible = Fld044Visible; Editable = Fld044Editable; }
                field(F045; Rec.Fld045) { ApplicationArea = All; Visible = Fld045Visible; Editable = Fld045Editable; }
                field(F046; Rec.Fld046) { ApplicationArea = All; Visible = Fld046Visible; Editable = Fld046Editable; }
                field(F047; Rec.Fld047) { ApplicationArea = All; Visible = Fld047Visible; Editable = Fld047Editable; }
                field(F048; Rec.Fld048) { ApplicationArea = All; Visible = Fld048Visible; Editable = Fld048Editable; }
                field(F049; Rec.Fld049) { ApplicationArea = All; Visible = Fld049Visible; Editable = Fld049Editable; }
                field(F050; Rec.Fld050) { ApplicationArea = All; Visible = Fld050Visible; Editable = Fld050Editable; }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Fld001Editable := Fld001Editable;
    end;

    trigger OnOpenPage()
    begin
        if not Rec.HasFilter then
            if Rec.FindFirst() then
                Rec.InitFirstLineAsCaptions(Rec);
        InitVisibility();
        InitEditable();
    end;

    local procedure InitEditable()
    begin
        Fld001Editable := GetEditable(Rec.FieldNo(Fld001));
        Fld002Editable := GetEditable(Rec.FieldNo(Fld002));
        Fld003Editable := GetEditable(Rec.FieldNo(Fld003));
        Fld004Editable := GetEditable(Rec.FieldNo(Fld004));
        Fld005Editable := GetEditable(Rec.FieldNo(Fld005));
        Fld006Editable := GetEditable(Rec.FieldNo(Fld006));
        Fld007Editable := GetEditable(Rec.FieldNo(Fld007));
        Fld008Editable := GetEditable(Rec.FieldNo(Fld008));
        Fld009Editable := GetEditable(Rec.FieldNo(Fld009));
        Fld010Editable := GetEditable(Rec.FieldNo(Fld010));
        Fld011Editable := GetEditable(Rec.FieldNo(Fld011));
        Fld012Editable := GetEditable(Rec.FieldNo(Fld012));
        Fld013Editable := GetEditable(Rec.FieldNo(Fld013));
        Fld014Editable := GetEditable(Rec.FieldNo(Fld014));
        Fld015Editable := GetEditable(Rec.FieldNo(Fld015));
        Fld016Editable := GetEditable(Rec.FieldNo(Fld016));
        Fld017Editable := GetEditable(Rec.FieldNo(Fld017));
        Fld018Editable := GetEditable(Rec.FieldNo(Fld018));
        Fld019Editable := GetEditable(Rec.FieldNo(Fld019));
        Fld020Editable := GetEditable(Rec.FieldNo(Fld020));
        Fld021Editable := GetEditable(Rec.FieldNo(Fld021));
        Fld022Editable := GetEditable(Rec.FieldNo(Fld022));
        Fld023Editable := GetEditable(Rec.FieldNo(Fld023));
        Fld024Editable := GetEditable(Rec.FieldNo(Fld024));
        Fld025Editable := GetEditable(Rec.FieldNo(Fld025));
        Fld026Editable := GetEditable(Rec.FieldNo(Fld026));
        Fld027Editable := GetEditable(Rec.FieldNo(Fld027));
        Fld028Editable := GetEditable(Rec.FieldNo(Fld028));
        Fld029Editable := GetEditable(Rec.FieldNo(Fld029));
        Fld030Editable := GetEditable(Rec.FieldNo(Fld030));
        Fld031Editable := GetEditable(Rec.FieldNo(Fld031));
        Fld032Editable := GetEditable(Rec.FieldNo(Fld032));
        Fld033Editable := GetEditable(Rec.FieldNo(Fld033));
        Fld034Editable := GetEditable(Rec.FieldNo(Fld034));
        Fld035Editable := GetEditable(Rec.FieldNo(Fld035));
        Fld036Editable := GetEditable(Rec.FieldNo(Fld036));
        Fld037Editable := GetEditable(Rec.FieldNo(Fld037));
        Fld038Editable := GetEditable(Rec.FieldNo(Fld038));
        Fld039Editable := GetEditable(Rec.FieldNo(Fld039));
        Fld040Editable := GetEditable(Rec.FieldNo(Fld040));
        Fld041Editable := GetEditable(Rec.FieldNo(Fld041));
        Fld042Editable := GetEditable(Rec.FieldNo(Fld042));
        Fld043Editable := GetEditable(Rec.FieldNo(Fld043));
        Fld044Editable := GetEditable(Rec.FieldNo(Fld044));
        Fld045Editable := GetEditable(Rec.FieldNo(Fld045));
        Fld046Editable := GetEditable(Rec.FieldNo(Fld046));
        Fld047Editable := GetEditable(Rec.FieldNo(Fld047));
        Fld048Editable := GetEditable(Rec.FieldNo(Fld048));
        Fld049Editable := GetEditable(Rec.FieldNo(Fld049));
        Fld050Editable := GetEditable(Rec.FieldNo(Fld050));
    end;

    local procedure InitVisibility()
    begin
        Fld001Visible := GetVisibility(Rec.FieldNo(Fld001));
        Fld002Visible := GetVisibility(Rec.FieldNo(Fld002));
        Fld003Visible := GetVisibility(Rec.FieldNo(Fld003));
        Fld004Visible := GetVisibility(Rec.FieldNo(Fld004));
        Fld005Visible := GetVisibility(Rec.FieldNo(Fld005));
        Fld006Visible := GetVisibility(Rec.FieldNo(Fld006));
        Fld007Visible := GetVisibility(Rec.FieldNo(Fld007));
        Fld008Visible := GetVisibility(Rec.FieldNo(Fld008));
        Fld009Visible := GetVisibility(Rec.FieldNo(Fld009));
        Fld010Visible := GetVisibility(Rec.FieldNo(Fld010));
        Fld011Visible := GetVisibility(Rec.FieldNo(Fld011));
        Fld012Visible := GetVisibility(Rec.FieldNo(Fld012));
        Fld013Visible := GetVisibility(Rec.FieldNo(Fld013));
        Fld014Visible := GetVisibility(Rec.FieldNo(Fld014));
        Fld015Visible := GetVisibility(Rec.FieldNo(Fld015));
        Fld016Visible := GetVisibility(Rec.FieldNo(Fld016));
        Fld017Visible := GetVisibility(Rec.FieldNo(Fld017));
        Fld018Visible := GetVisibility(Rec.FieldNo(Fld018));
        Fld019Visible := GetVisibility(Rec.FieldNo(Fld019));
        Fld020Visible := GetVisibility(Rec.FieldNo(Fld020));
        Fld021Visible := GetVisibility(Rec.FieldNo(Fld021));
        Fld022Visible := GetVisibility(Rec.FieldNo(Fld022));
        Fld023Visible := GetVisibility(Rec.FieldNo(Fld023));
        Fld024Visible := GetVisibility(Rec.FieldNo(Fld024));
        Fld025Visible := GetVisibility(Rec.FieldNo(Fld025));
        Fld026Visible := GetVisibility(Rec.FieldNo(Fld026));
        Fld027Visible := GetVisibility(Rec.FieldNo(Fld027));
        Fld028Visible := GetVisibility(Rec.FieldNo(Fld028));
        Fld029Visible := GetVisibility(Rec.FieldNo(Fld029));
        Fld030Visible := GetVisibility(Rec.FieldNo(Fld030));
        Fld031Visible := GetVisibility(Rec.FieldNo(Fld031));
        Fld032Visible := GetVisibility(Rec.FieldNo(Fld032));
        Fld033Visible := GetVisibility(Rec.FieldNo(Fld033));
        Fld034Visible := GetVisibility(Rec.FieldNo(Fld034));
        Fld035Visible := GetVisibility(Rec.FieldNo(Fld035));
        Fld036Visible := GetVisibility(Rec.FieldNo(Fld036));
        Fld037Visible := GetVisibility(Rec.FieldNo(Fld037));
        Fld038Visible := GetVisibility(Rec.FieldNo(Fld038));
        Fld039Visible := GetVisibility(Rec.FieldNo(Fld039));
        Fld040Visible := GetVisibility(Rec.FieldNo(Fld040));
        Fld041Visible := GetVisibility(Rec.FieldNo(Fld041));
        Fld042Visible := GetVisibility(Rec.FieldNo(Fld042));
        Fld043Visible := GetVisibility(Rec.FieldNo(Fld043));
        Fld044Visible := GetVisibility(Rec.FieldNo(Fld044));
        Fld045Visible := GetVisibility(Rec.FieldNo(Fld045));
        Fld046Visible := GetVisibility(Rec.FieldNo(Fld046));
        Fld047Visible := GetVisibility(Rec.FieldNo(Fld047));
        Fld048Visible := GetVisibility(Rec.FieldNo(Fld048));
        Fld049Visible := GetVisibility(Rec.FieldNo(Fld049));
        Fld050Visible := GetVisibility(Rec.FieldNo(Fld050));
    end;

    procedure GetEditable(FieldNo: Integer) IsEditable: Boolean
    begin
        /* Only show Columns with Caption */
        IsEditable := DMTGenBufferFieldCaptions.HasCaption(FieldNo);
    end;

    procedure GetVisibility(FieldNo: Integer) IsEditable: Boolean
    begin
        /* Only show Columns with Caption */
        IsEditable := DMTGenBufferFieldCaptions.HasCaption(FieldNo);
    end;

    var
        DMTGenBufferFieldCaptions: Codeunit DMTSessionStorage;
        [InDataSet]
        Fld001Editable, Fld002Editable, Fld003Editable, Fld004Editable, Fld005Editable, Fld006Editable, Fld007Editable, Fld008Editable, Fld009Editable, Fld010Editable,
        Fld011Editable, Fld012Editable, Fld013Editable, Fld014Editable, Fld015Editable, Fld016Editable, Fld017Editable, Fld018Editable, Fld019Editable, Fld020Editable,
        Fld021Editable, Fld022Editable, Fld023Editable, Fld024Editable, Fld025Editable, Fld026Editable, Fld027Editable, Fld028Editable, Fld029Editable, Fld030Editable,
        Fld031Editable, Fld032Editable, Fld033Editable, Fld034Editable, Fld035Editable, Fld036Editable, Fld037Editable, Fld038Editable, Fld039Editable, Fld040Editable,
        Fld041Editable, Fld042Editable, Fld043Editable, Fld044Editable, Fld045Editable, Fld046Editable, Fld047Editable, Fld048Editable, Fld049Editable, Fld050Editable : Boolean;
        [InDataSet]
        Fld001Visible, Fld002Visible, Fld003Visible, Fld004Visible, Fld005Visible, Fld006Visible, Fld007Visible, Fld008Visible, Fld009Visible, Fld010Visible,
        Fld011Visible, Fld012Visible, Fld013Visible, Fld014Visible, Fld015Visible, Fld016Visible, Fld017Visible, Fld018Visible, Fld019Visible, Fld020Visible,
        Fld021Visible, Fld022Visible, Fld023Visible, Fld024Visible, Fld025Visible, Fld026Visible, Fld027Visible, Fld028Visible, Fld029Visible, Fld030Visible,
        Fld031Visible, Fld032Visible, Fld033Visible, Fld034Visible, Fld035Visible, Fld036Visible, Fld037Visible, Fld038Visible, Fld039Visible, Fld040Visible,
        Fld041Visible, Fld042Visible, Fld043Visible, Fld044Visible, Fld045Visible, Fld046Visible, Fld047Visible, Fld048Visible, Fld049Visible, Fld050Visible : Boolean;
}
