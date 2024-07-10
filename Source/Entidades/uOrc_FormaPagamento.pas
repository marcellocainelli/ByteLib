unit uOrc_FormaPagamento;

interface

uses
  Model.Entidade.Interfaces, Data.DB, System.SysUtils;

Type
  TOrc_FormaPagamento = class(TInterfacedObject, iEntidade)
    private
      FEntidadeBase: iEntidadeBase<iEntidade>;
      procedure OnNewRecord(DataSet: TDataSet);
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

{ TOrc_FormaPagamento }

constructor TOrc_FormaPagamento.Create;
begin
  FEntidadeBase:= TEntidadeBase<iEntidade>.New(Self);
  FEntidadeBase.TextoSQL('Select * from ORC_FORMAPAGAMENTO');
  InicializaDataSource;
end;

destructor TOrc_FormaPagamento.Destroy;
begin
  inherited;
end;

class function TOrc_FormaPagamento.New: iEntidade;
begin
  Result:= Self.Create;
end;

function TOrc_FormaPagamento.EntidadeBase: iEntidadeBase<iEntidade>;
begin
  Result:= FEntidadeBase;
end;

function TOrc_FormaPagamento.Consulta(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL(FEntidadeBase.TextoSQL);
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

function TOrc_FormaPagamento.InicializaDataSource(Value: TDataSource): iEntidade;
begin
  Result:= Self;
  if Value = nil then
    Value:= FEntidadeBase.DataSource;
  FEntidadeBase.Iquery.SQL('Select * From ORC_FORMAPAGAMENTO Where 1 <> 1');
  Value.DataSet:= FEntidadeBase.Iquery.Dataset;
end;

procedure TOrc_FormaPagamento.ModificaDisplayCampos;
begin

end;

function TOrc_FormaPagamento.DtSrc: TDataSource;
begin
  Result:= FEntidadeBase.DataSource;
end;

procedure TOrc_FormaPagamento.OnNewRecord(DataSet: TDataSet);
begin

end;

end.
