//+------------------------------------------------------------------+
//|                                   Copyright 2017, Erlon F. Souza |
//|                                       https://github.com/erlonfs |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, Erlon F. Souza"
#property link      "https://github.com/erlonfs"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <BadRobot.Framework\BadRobotPrompt.mqh>

class ElephantWalk : public BadRobotPrompt
{
   private:
   
   	MqlRates _rates[];   	
   	double _high;
		double _low;	   
		int _sizeOfBar;	   
		bool _wait;
	
		bool _match;
		datetime _timeMatch;
	   
   	
   	bool GetBuffers() {
   	
   	   if(_wait) return true;
   	      	   	
   		ZeroMemory(_rates);
   		ArraySetAsSeries(_rates, true);
   		ArrayFree(_rates); 
   
   		int copiedRates = CopyRates(GetSymbol(), GetPeriod(), 0, 2, _rates);
   
   		return copiedRates > 0;

	   }
	   
	   bool IsCandlePositive(MqlRates &rate){
	      return rate.close >= rate.open;
	   }
	   
	   bool IsCandleNegative(MqlRates &rate){
	      return rate.open > rate.close;
	   }  
	   
	   bool FindElephant(){	   
	   	   	      
         bool isFound = false;
         
         if(!IsNewCandle())
         {
            return isFound;
         }
         
	      _high = _rates[1].high;
	      _low = _rates[1].low;	     
	      
	      isFound = NormalizeDouble((_high - _low), _Digits)  >= ToPoints(_sizeOfBar);
	      
	      bool isCandlePositive = IsCandlePositive(_rates[1]);
	      
	      if(isFound != _match){
	         
	         if(isFound)
	         {
	            _timeMatch = _rates[1].time;
	            Draw(isCandlePositive ? _high : _low, _timeMatch, isCandlePositive);
	            ShowMessage("Barra elefante de " + DoubleToString(ToPoints(_sizeOfBar), _Digits) + " encontrado.");
	         }	         
	      }
	      
	      _match = isFound;
	      	      	        	    	      	      	    	      
	      return isFound;
	   
	   }
	   
	void Draw(double price, datetime time, bool isCandlePositive)
	{	
		//ClearDraw(time);
		string objName = "ARROW" + DoubleToString(price) + TimeToString(time);
		ObjectCreate(0, objName, OBJ_ARROW_UP, 0, time, price);

		ObjectSetInteger(0, objName, OBJPROP_COLOR, isCandlePositive ? clrGreen : clrRed);
		ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
		ObjectSetInteger(0, objName, OBJPROP_BACK, false);
		ObjectSetInteger(0, objName, OBJPROP_FILL, true);
		ObjectSetInteger(0, objName, OBJPROP_BGCOLOR, isCandlePositive ? clrGreen : clrRed);
	}

	void ClearDraw(datetime time) {

		string objName = "ARROW" + (string)time;

		if (ObjectFind(0, objName) != 0) {
			ObjectDelete(0, objName);
		}
	}
   
   public:
         	 	   
   	void OnTickHandler() {
   	
   	   SetInfo("TAM CANDLE "+ DoubleToString(_high - _low, _Digits) + "/" + DoubleToString(ToPoints(_sizeOfBar), _Digits) + 
   	                 "\nMIN "+ DoubleToString(_low, _Digits) + " MAX " + DoubleToString(_high, _Digits));
   	   	
   		if(GetBuffers()){   	
   		      		   
   		   if(_wait || FindElephant()){
   		   
   		      _wait = true;
   		         		     
      		   if(IsCandlePositive(_rates[1])){
      		         		      		   
      		      double _entrada = _high + ToPoints(GetSpread());         			
              
         			if (GetLastPrice() >= _entrada && !HasPositionOpen()) {         
         			   _wait = false;
         				Buy(_entrada);           				          
         			}             		     		
         			
      		   }
      		   
      		   if(IsCandleNegative(_rates[1])){
      		         		   
      		      double _entrada = _low - ToPoints(GetSpread());
              
         			if (GetLastPrice() <= _entrada && !HasPositionOpen()) {         
         			   _wait = false;
         				Sell(_entrada);     
        			   }         		         			
      		   }
   		      
               if(GetLastPrice() < _low - ToPoints(GetSpread())){
      			   _wait = false;
      			   ShowMessage("Compra Cancelada!");
      			   return;
      			}      			      			
      			
      			if(GetLastPrice() > _high + ToPoints(GetSpread())){
      			   _wait = false;
      			   ShowMessage("Venda Cancelada!");
      			   return;
      			}
      		  
            }
   		   
   		}   	
   		
   	};
   	
      void OnTradeHandler()
      {      
         _wait = false;
      }
                 
      void SetSizeOfBar(int value){
         _sizeOfBar = value;
      } 
   	
};

