unit uMDFe;

interface

uses
  Model.Entidade.Interfaces, Model.Conexao.Interfaces, Data.DB, System.SysUtils;

Type
  TMDFe = class(TInterfacedObject, iEntidade)
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

constructor TMDFe.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self, AConn);
  FEntidadeBase.TextoSQL('SELECT * FROM MDFE_BASE Where COD_FILIAL = :pCodFilial ');
  InicializaDataSource;
end;

destructor TMDFe.Destroy;
begin
  inherited;
end;

class function TMDFe.New(AConn: iConexao): iEntidade;
begin
  Result:= Self.Create(AConn);
end;

function TMDFe.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TMDFe.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + 'and ID = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + 'and DTEMISSAO = :pData';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('DTEMISSAO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TMDFe.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from MDFE_BASE Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TMDFe.ModificaDisplayCampos;
begin
  {$IFDEF MSWINDOWS}
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('PESO')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CAP_KG')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('CAP_M3')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('TARA')).DisplayFormat:= '#,0.000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('VALOR')).currency:= True;
  {$ENDIF}
end;

function TMDFe.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
