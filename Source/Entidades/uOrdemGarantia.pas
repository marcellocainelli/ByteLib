unit uOrdemGarantia;

interface

uses
  Model.Entidade.Interfaces, Data.DB, uLib, System.SysUtils;

Type
  TOrdemGarantia = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: iEntidade;
      function EntidadeBase: iEntidadeBase<iEntidade>;
      function Consulta(Value: TDataSource): iEntidade;
      function InicializaDataSource(Value: TDataSource): iEntidade;
      procedure ModificaDisplayCampos;
  end;

implementation

uses
  uEntidadeBase;

{ TOrdemGarantia }

constructor TOrdemGarantia.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('select * from ORD_GARANTIA ');
end;

destructor TOrdemGarantia.Destroy;
begin
  inherited;
end;

class function TOrdemGarantia.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrdemGarantia.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrdemGarantia.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  FEntidadeBase.Iquery.IndexFieldNames('DESCRICAO');
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrdemGarantia.InicializaDataSource(Value: TDataSource): iEntidade;
begin

end;

procedure TOrdemGarantia.ModificaDisplayCampos;
begin

end;

end.
