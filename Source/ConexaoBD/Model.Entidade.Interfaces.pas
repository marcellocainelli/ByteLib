unit Model.Entidade.Interfaces;

interface

uses
  Data.DB, System.Classes, Model.Conexao.Interfaces;

type
  iEntidadeBase<T> = interface
    ['{92115277-3ADA-479B-898C-D2D496577CA9}']
    function Salva(Value: TDataSource = nil): iEntidadeBase<T>;
    function Exclui(Value: TDataSource = nil): iEntidadeBase<T>;
    function AddParametro(NomeParametro: String; ValorParametro: Variant; DataType: TFieldType): iEntidadeBase<T>; overload;
    function AddParametro(NomeParametro: String; ValorParametro: integer): iEntidadeBase<T>; overload;
    function RefreshDataSource(Value: TDataSource = nil): iEntidadeBase<T>;
    function SaveIfChangeCount(DataSource: TDataSource = nil): iEntidadeBase<T>;
    function InsertBeforePost(DataSource: TDataSource = nil; AEvent: TDataSetNotifyEvent = nil): iEntidadeBase<T>;
    function Validate(Value: TDataSource = nil; ANomeCampo: string = ''; AEvent: TFieldNotifyEvent = nil): iEntidadeBase<T>;
    function SetReadOnly(Value: TDataSource = nil; ANomeCampo: string = ''; AReadOnly: boolean = false): iEntidadeBase<T>;
    function CalcFields(AEvent: TDatasetNotifyEvent): iEntidadeBase<T>;
    function CriaCampo(ADataSource: TDataSource = nil; ANomeCampo: string = ''; ADataType: TFieldType = ftUnknown): iEntidadeBase<T>;
    function &End : T;

    function TextoSQL(pValue: String): String; overload;
    function TextoSQL: String; overload;
    function TextoPesquisa(pValue: String): String; overload;
    function TextoPesquisa: String; overload;
    function TipoPesquisa(pValue: Integer ): Integer; overload;
    function TipoPesquisa: Integer ; overload;
    function RegraPesquisa(pValue: String): String; overload;
    function RegraPesquisa: String; overload;
    function TipoConsulta(pValue: String ): iEntidadeBase<T>; overload;
    function TipoConsulta: String ; overload;
    function Inativos(pValue: boolean): boolean; overload;
    function Inativos: boolean; overload;
    function Iquery: iQuery; overload;
    function DataSource: TDataSource; overload;
  end;

  iEntidade = interface
    ['{896BAE51-DA7D-4D43-B145-23EF809E6D32}']
    function EntidadeBase: iEntidadeBase<iEntidade>;
    function Consulta(Value: TDataSource = nil): iEntidade;
    function InicializaDataSource(Value: TDataSource = nil): iEntidade;
    function DtSrc: TDataSource;
    procedure ModificaDisplayCampos;
  end;

  iEntidadeProduto = interface
    ['{C12867A3-E384-4F47-BC31-566CFC87907E}']
    function EntidadeBase: iEntidadeBase<iEntidadeProduto>;
    function Consulta(Value: TDataSource = nil): iEntidadeProduto;
    function InicializaDataSource(Value: TDataSource = nil): iEntidadeProduto;
    function DtSrc: TDataSource;
    procedure ModificaDisplayCampos;

    function ValidaDepto(pValue: boolean): iEntidadeProduto; overload;
    function ValidaDepto: boolean; overload;
    function CodDeptoUsuario(pValue: Integer ): iEntidadeProduto; overload;
    function CodDeptoUsuario: Integer ; overload;
    function TipoConsulta(pValue: String ): iEntidadeProduto; overload;
    function TipoConsulta: String ; overload;
  end;

implementation

end.
