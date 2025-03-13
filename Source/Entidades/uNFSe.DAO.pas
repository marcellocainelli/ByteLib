unit uNFSe.DAO;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TNfse = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
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

constructor TNfse.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from NFSERVICO Where COD_FILIAL = :pCodFilial ');
  InicializaDataSource;
end;

destructor TNfse.Destroy;
begin
  inherited;
end;

class function TNfse.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfse.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfse.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  Case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= FEntidadeBase.TextoSQL + ' and ID = :mParametro';
    1: vTextoSQL:= FEntidadeBase.TextoSQL + ' and RPS_NUMERO = :mParametro';
    2: vTextoSQL:= FEntidadeBase.TextoSQL + ' and DTEMISSAO = :pData';
    3: vTextoSQL:= FEntidadeBase.TextoSQL + ' and NOME Containing :mParametro';
    4: vTextoSQL:= FEntidadeBase.TextoSQL + ' and NUMNFISCAL =  :mParametro';
  end;
  FEntidadeBase.AddParametro('mParametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfse.InicializaDataSource(Value: TDataSource): iEntidade;
var
  vTextoSql: String;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSql:= 'Select * from NFSERVICO Where 1 <> 1';
  FEntidadeBase.Iquery.SQL(vTextoSql);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfse.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('aliquota')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vl_servicos')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('basecalculo')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vl_iss')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vl_liquidonfse')).currency:= True;
end;

function TNfse.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
