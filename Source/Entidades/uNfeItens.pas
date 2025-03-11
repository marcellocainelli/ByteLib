unit uNfeItens;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;
Type
  TNfeItens = class(TInterfacedObject, iEntidade)
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

{ TNfeItens }

constructor TNfeItens.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TipoPesquisa(0);
  FEntidadeBase.TextoSQL(
    'Select NFI.*, P.CLASFISCAL, P.IPI_SAIDA, P.ICMS as CODICMS, P.LISTSERV, ' +
    'P.PPB, P.COD_BARRA, P.COD_ANP, P.COMPLEMENTO, P.CEST, P.VOLUME, P.PESO ' +
    'From NFISCAL_ITENS NFI ' +
    'Join PRODUTOS P On (P.COD_PROD = NFI.COD_PROD) ' +
    'Where (1 = 1) and  ');
  InicializaDataSource;
end;

destructor TNfeItens.Destroy;
begin
  inherited;
end;

class function TNfeItens.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfeItens.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfeItens.Consulta(Value: TDataSource): iEntidade;
var
  vTextoSQL: string;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  vTextoSQL:= FEntidadeBase.TextoSql;
  case FEntidadeBase.TipoPesquisa of
    0: vTextoSQL:= vTextoSql + 'NFI.NFNUMERO = :Parametro';
  end;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NFNUMERO');
  FEntidadeBase.Iquery.SQL(vTextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
  FEntidadeBase.CriaCampo(Value, 'VrCalculado', ftCurrency);
  ModificaDisplayCampos;
  Value.DataSet.Open;
end;

function TNfeItens.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NFNUMERO');
  FEntidadeBase.AddParametro('Parametro', '-1', ftString);
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSql + 'NFI.NFNUMERO = :Parametro');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfeItens.ModificaDisplayCampos;
begin
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('quantidade')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('preco_vend')).DisplayFormat:= '#,0.0000';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('vrcalculado')).currency:= True;
end;

function TNfeItens.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
