unit uMDFe_NFes;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils;

Type
  TMDFe_NFes = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create(AConn: iConexao = nil);
      destructor Destroy; override;
      class function New(AConn: iConexao = nil): iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource = nil): iEntidade;
      function InicializaDataSource(Value: TDataSource = nil): iEntidade;
      function DtSrc: TDataSource;
      procedure ModificaDisplayCampos;
  end;
implementation
uses
  uEntidadeBase;

{ TNfse }

constructor TMDFe_NFes.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TextoSQL('SELECT * FROM MDFE_NFES Where 1=1 ');
  InicializaDataSource;
end;

destructor TMDFe_NFes.Destroy;
begin
  inherited;
end;

class function TMDFe_NFes.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TMDFe_NFes.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMDFe_NFes.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and ID_MDFE = :mParametro';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMDFe_NFes.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from MDFE_NFES Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMDFe_NFes.ModificaDisplayCampos;
begin
  {$IFDEF MSWINDOWS}
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PESO')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
  {$ENDIF}
end;

function TMDFe_NFes.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
