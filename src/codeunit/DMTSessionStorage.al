codeunit 110001 "DMTSessionStorage"
{
    SingleInstance = true;
    procedure AddCaption(FieldNo: Integer; CaptionNew: text)
    begin
        if Captions.ContainsKey(FieldNo) then
            Captions.Set(FieldNo, CaptionNew)
        else
            Captions.Add(FieldNo, CaptionNew);
    end;

    procedure GetCaption(FieldNo: Integer) Caption: Text
    begin
        if not Captions.Get(FieldNo, Caption) then
            exit;
    end;

    procedure HasCaption(FieldNo: Integer): Boolean
    begin
        exit(Captions.ContainsKey(FieldNo));
    end;

    procedure DisposeCaptions()
    begin
        Clear(Captions);
    end;

    procedure GetNoOfCaptions(): Integer
    begin
        exit(Captions.Keys.Count);
    end;

    procedure SetLicenseInfo(ObjectType: Enum DMTObjTypes; ObjectIDsInLicense: List of [Integer])
    begin
        if ObjIDsInLicenseDict.ContainsKey(ObjectType) then
            ObjIDsInLicenseDict.Remove(ObjectType);
        ObjIDsInLicenseDict.Add(ObjectType, ObjectIDsInLicense);
    end;

    procedure GetLicenseInfo(var ObjectIDsInLicense: List of [Integer]; ObjectType: Enum DMTObjTypes) OK: Boolean
    begin
        Clear(ObjectIDsInLicense);
        OK := ObjIDsInLicenseDict.ContainsKey(ObjectType);
        if OK then
            ObjectIDsInLicense := ObjIDsInLicenseDict.Get(ObjectType);
    end;

    internal procedure DisposeLicenseInfo()
    begin
        Clear(ObjIDsInLicenseDict);
    end;

    var
        Captions: Dictionary of [Integer, Text];
        ObjIDsInLicenseDict: Dictionary of [Enum DMTObjTypes, List of [Integer]];
}