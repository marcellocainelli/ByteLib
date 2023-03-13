unit Model.Conexao.Interfaces;

interface

uses
  Data.DB, System.Classes;

type

  TipoConn = (FDConn);

  iConexao = interface
    ['{253621FF-A06A-48B8-8F63-211FAE6B5C70}']
    function Connection: TCustomConnection;
    function CaminhoBanco: String;
  end;

  iQuery = interface
    ['{444A687A-2732-4746-BA8C-399C98622CB2}']
    function SQL(Value: String): iQuery;
    function Dataset: TDataSet;
    function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iQuery; overload;
    function AddParametro(NomeParametro: String; ValorParametro: integer): iQuery; overload;
    function Close: iQuery;
    function ExecQuery(Value: String): iQuery;
    function Salva(Commit: Boolean = True): iQuery;
    function ApplyUpdates: iQuery;
    function IndexFieldNames(FieldName: String): iQuery;
    function StartTransaction: iQuery;
    function InTransaction: Boolean;
    function Commit: iQuery;
    function Rollback: iQuery;
    function ChangeCount(DataSet: TDataSet): integer;
    function GetFieldNames(Table: string; List: TStrings): iQuery;
    function SetMode(pModo: string): iQuery;
    function CalcFields(AEvent: TDataSetNotifyEvent): iQuery;
  end;

  iTable = interface
    ['{F9E595CC-4E5F-472B-B817-B58CB9AD0816}']
    function Tabela: TDataSet;
    function CriaDataSet: iTable;
    function CopiaDataSet(DataSet: TDataSet): iTable;
    function CloneCursor(DataSet: TDataSet): iTable;
    function IndexFieldNames(FieldName: String): iTable;
    function CriaCampo(ANomeCampo: string = ''; ADataType: TFieldType = ftUnknown): iTable;
    function CalcFields(AEvent: TDataSetNotifyEvent): iTable;
  end;

  iScript = interface
    ['{EC45E6C4-980B-4E83-8888-9D239C66FE63}']
    function Clear: iScript;
    function Add: iScript;
    function SQLAdd(AValue: String): iScript;
    function SQLSaveToFile(AValue: String): iScript;
    function ValidateAll: Boolean;
    function ExecuteAll: Boolean;
    function StartTransaction: iScript;
    function InTransaction: Boolean;
    function Commit: iScript;
    function Rollback: iScript;
  end;

implementation

end.
