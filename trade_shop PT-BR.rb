=begin
-----------------------------------------------------
                   TRADE SHOP
-----------------------------------------------------
AUTOR: KUSMA
-----------------------------------------------------
#LIVRE PARA QAULQUER USO, INCLUSIVE COMERCIAL, DESDE
QUE CREDITADO
----------------------------------------------------
FUNÇÃO: CRIA UMA LOJA DE TROCA, NA QUAL O JOGADOR
PODE TROCAR ITENS COLETÁVEIS POR OUTROS ITENS
----------------------------------------------------
COMO UTILIZAR: COLOCAR ESSE SCRIPT NO SEU EDITOR DE
SCRIPT ACIMA DO MAIN

NO DATA BASE (BASE DE DADOS), ADICIONAR
NOS ITENS/ARMAS/ARMADURAS QUE SERÃO COMERCIALIZADOS
NA LOJA AS SEGUINTES INFORMAÇÕES, NO CAMPO DE NOTAS 
(NOTE TAG):

<item_trade: 24><trade_price: 2>. 

NESSE
EXEMPLO O ITEM EM QUESTÃO IRÁ CUSTAR 2 (item_price) 
UNIDADES DO ITEM 24(item_trade).

OS ITENS COLETÁVEIS DEVEM SER CRIADOS NECESSÁRIAMENTE
NA ABA ITENS E CONTER EM SUAS NOTAS O SEGUINTE:
<tradable>

PARA ACESSAR A LOJA, BASTA USAR UM SCRIPT_CALL (CHAMAR
SCRIPT) E COLOCAR O SEGUINTE:

trade_shop([1,2,3,9],[13],[10])

OS VALORES DENTRO DOS PRIMEIROS COLCHETES SÃO OS ITENS
QUE ESTARÃO DISPONÍVEIS NESSA LOJA, NESSE EXEMPLO 
ESTARÃO DISPONÍVEIS OS ITENS 1,2,3 E 9 DO DATA BASE

OS SEGUNDOS COLCHETES SE REFERE ÀS ARMAS DISPONÍVEIS.
NESSE EXEMPLO ESTARÁ DISPONÍVEL A ARMA 13 DO DATA BASE.

OS TERCEIROS COLCHETES COLCHETES SE REFERE ÀS ARMADURAS.
NESSE EXEMPLO A ARMADURA 10 DO DATA BASE ESTARÁ NA LOJA.
----------------------------------------------------------
=end

module Exl

  @list_item_trade = []
  @list_weapon_trade = []
  @list_armor_trade = []
  @list_tradable =[]
  
   
  class << self
    attr_accessor :list_item_trade, :list_weapon_trade, :list_armor_trade, :list_tradable
  end #class
end #Exl

class RPG::BaseItem
         
    attr_accessor :item_trade, :trade_price; :tradable_item;
   

    def my_initialize
        
      if self.note=~(/<item_trade:\s+([^>]+)>/im) #match
        @item_trade = $1.to_i #usando match o $1 é o resultado
      end
      if self.note=~(/<trade_price:\s+([^>]+)>/im)
        @trade_price = $1.to_i
      end

      @tradable_item = self.note.include?"<tradable>"
      if @tradable_item
        Exl.list_tradable.push(self)
      end
      
    end #initialize
end #class RPG::Item

class << DataManager # "<<"" permite editar os métodos estáticos da classe 
    
  
  alias :test_init :init
  def init
    test_init
    $data_items.each do |item|
      item.my_initialize if item #o mesmo que if item==nill
    end
    $data_weapons.each do |item|
      item.my_initialize if item #o mesmo que if item==nill
    end
    $data_armors.each do |item|
      item.my_initialize if item #o mesmo que if item==nill
    end
  end #init
    
end #data Manager

=begin
class << xxx permite editar os métodos estáticos da classe
os métodos estáticos são aqueles que não pertencem a nenhuma instância e 
podem ser chamados diretamente de fora da classe/módulo
=end



class Game_Interpreter
  
  def trade_shop(item_trade,weapon_trade,armor_trade)
    
    Exl.list_item_trade = item_trade
    Exl.list_weapon_trade = weapon_trade
    Exl.list_armor_trade = armor_trade
    SceneManager.call(Trade_Shop_Scene)
  end #trade_shop

end # Game_Interpreter

class Window_Trade < Window_Selectable

  def initialize(x, y, width, height)
    @list_market=[]
    make_list_market
    super
    draw_list
    activate
    select(0)
  end #initialize

  def make_list_market
          
    for i in 0...Exl.list_item_trade.size
      @list_market.push($data_items[Exl.list_item_trade[i]])
    end

    for i in 0...Exl.list_weapon_trade.size
      @list_market.push($data_weapons[Exl.list_weapon_trade[i]])
    end

    for i in 0...Exl.list_armor_trade.size
      @list_market.push($data_armors[Exl.list_armor_trade[i]])
    end

  end #make_list_market


  def draw_list
    self.contents.clear
    for i in 0...@list_market.size
    rect = item_rect(i)
    if $game_party.item_number($data_items[@list_market[i].item_trade]) >= @list_market[i].trade_price
      auxiliar_color=true
    else
      auxiliar_color=false
    end
  
    self.change_color(normal_color,auxiliar_color)
    self.draw_icon(@list_market[i].icon_index, rect.x, rect.y) # Vamos desenhar os ícones.
    rect.x += 24 # Vamos afastar o texto 24 pixels para a direita.
    self.draw_text(rect, @list_market[i].name)
    rect.x+=196
    self.draw_icon($data_items[@list_market[i].item_trade].icon_index, rect.x, rect.y)
    rect.x+=24
    self.draw_text(rect,"x#{@list_market[i].trade_price}")       
    end
  end #draw_list

  def current_item
    return @list_market[index]
  end #current_item
 
  def item_max
    #a lista não existe? 0. do contrário o tamanho da lista
    return @list_market.nil? ? 0: @list_market.size
  end #item_max



end #Window_Trade

class Trade_Shop_Scene < Scene_Base

  def start
    super
    @background = Sprite.new
    @background.bitmap = SceneManager.background_bitmap #colocando o fundo como um print da cena anterior
    @janela_fantasia = Window_Base.new(0,0,0,0)

    @janela_descricao = Window_Base.new(0,0,Graphics.width,@janela_fantasia.fitting_height(2))
    
    @janela_item = Window_Trade.new(0,@janela_descricao.height,Graphics.width*0.55,Graphics.height-@janela_descricao.height)

    @janela_qtd = Window_Base.new(@janela_item.width,@janela_descricao.height,Graphics.width*0.45,@janela_fantasia.fitting_height(1))
    
    @janela_qtd.draw_text_ex(0,0,"teste")

    @janela_trade = Window_Base.new(@janela_qtd.x, (@janela_qtd.y + @janela_qtd.height), @janela_qtd.width, (Graphics.height - @janela_qtd.y - @janela_qtd.height))
    
    inventory
    
    atualize_descricao
    atualize_qtd

   end #start

  def update
    ci = @janela_item.current_item
    super
    atualize_descricao  if ci!= @janela_item.current_item
    atualize_qtd if ci!= @janela_item.current_item
    if Input.trigger?(:C)
      execute_trade          
      end
    if Input.trigger?(:B)
      Sound.play_cancel
      SceneManager.return
    end
  end #update
  
  def atualize_descricao
    @janela_descricao.contents.clear
    @janela_descricao.draw_text_ex(0,0,@janela_item.current_item.description)
  end #atualize_descricao

  def atualize_qtd
    @janela_qtd.contents.clear
    @janela_qtd.draw_text_ex(0,0,"\eC[14]Possui:")
    @janela_qtd.draw_text_ex((@janela_qtd.width-48),0,$game_party.item_number(@janela_item.current_item))
  end #atualize_qtd

  def execute_trade
    price = @janela_item.current_item.trade_price
    trade = @janela_item.current_item.item_trade
    if $game_party.item_number($data_items[trade]) >= price
      $game_party.gain_item(@janela_item.current_item, 1)
      $game_party.gain_item($data_items[trade], -price)
      inventory
      atualize_qtd
      @janela_item.draw_list
      Sound.play_ok
      else
      Sound.play_buzzer
    end

  end #Execute_trade

  def inventory 
    jtx = 80
    @janela_trade.contents.clear
    @janela_trade.draw_text_ex(0,0,"\eC[14]Inventário:")
    for i in 0...Exl.list_tradable.size
        xi=jtx*(i%3)
        yi=32*(i/3)+32
        @janela_trade.draw_icon(Exl.list_tradable[i].icon_index,xi,yi)
        @janela_trade.draw_text_ex((xi+24),(yi),"X#{$game_party.item_number($data_items[Exl.list_tradable[i].id])}")
    end
  end #inventory


  end #Trade_Shop_Scene

