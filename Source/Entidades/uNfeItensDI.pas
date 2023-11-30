unit uNfeItensDI;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils, Byte.Lib;
Type
  TNfeItensDI = class(TInterfacedObject, iEntidade)
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

{ TNfeItensDI }

constructor TNfeItensDI.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from NFISCAL_ITENS_DI where NFISCAL_ITEM_SEQ = :Parametro');
  InicializaDataSource;
end;

destructor TNfeItensDI.Destroy;
begin
  inherited;
end;

class function TNfeItensDI.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TNfeItensDI.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TNfeItensDI.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.AddParametro('Parametro', FEntidadeBase.TextoPesquisa, ftString);
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  ModificaDisplayCampos;
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TNfeItensDI.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.IndexFieldNames('ID');
  FEntidadeBase.Iquery.SQL('select * from NFISCAL_ITENS_DI where (1 <> 1)');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TNfeItensDI.ModificaDisplayCampos;
begin

end;

function TNfeItensDI.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

end.
