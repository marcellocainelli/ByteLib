unit uNfeEntidade;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;

Type
  TNfeEntidade = class(TInterfacedObject, iEntidade)
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

{ TCliente }

constructor TNfeEntidade.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TipoPesquisa(0);
  FEntidadeBase.TextoSQL('Select * from NFISCAL Where cod_filial = :pCod_Filial and modelo = :pModelo and ');
  InicializaDataSource;
end;

destructor TNfeEntidade.Destroy;
begin
  inherited;
end;

class function TNfeEntidade.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfeEntidade.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfeEntidade.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + 'NUMERO = :Parametro';
    1: vTextoSQL:= vTextoSql + 'NUMNFISCAL = :Parametro';
    2: vTextoSQL:= vTextoSql + 'DTEMISSAO = :Parametro';
    3: vTextoSQL:= vTextoSql + 'NOME Containing :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUMERO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfeEntidade.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NUMERO');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + ' NUMERO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfeEntidade.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('dtemissao')).EditMask:= '!99/99/00;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vrbaseicms')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vricms')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vrtotalprodutos')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vrtotalnota')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('desconto')).currency:= True;
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('frete')).currency:= True;
end;

function TNfeEntidade.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
