unit uNfeDuplicatas;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;

Type
  TNfeDuplicatas = class(TInterfacedObject, iEntidade)
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

{ TNfeDuplicatas }

constructor TNfeDuplicatas.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NFISCAL_DUPLICATAS where NFNUMERO = :Parametro');
  InicializaDataSource;
end;

destructor TNfeDuplicatas.Destroy;
begin
  inherited;
end;

class function TNfeDuplicatas.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfeDuplicatas.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfeDuplicatas.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('NUMERO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfeDuplicatas.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('NUMERO');
  FEntidadeBase.Iquery.SQL('select * from NFISCAL_DUPLICATAS where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfeDuplicatas.ModificaDisplayCampos;
begin
  TDateField(FEntidadeBase.Iquery.Dataset.FieldByName('vencimento')).EditMask:= '!99/99/00;1;_';
  TFloatField(FEntidadeBase.Iquery.Dataset.FieldByName('valor')).currency:= True;
end;

function TNfeDuplicatas.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
