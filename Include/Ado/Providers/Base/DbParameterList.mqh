//+------------------------------------------------------------------+
//|                                              DbParameterList.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

//--------------------------------------------------------------------
#include "DbParameter.mqh"
#include "ClrObject.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
void DbParameterListAdd(const long,const long,string&,string&);
void DbParameterListRemove(const long,const long,string&,string&);
#import
//--------------------------------------------------------------------
/// \brief  \~russian Êëàññ, ïåðäñòàâëÿþùèé êîëëåêöèþ ïàðàìåòðîâ êîìàíäû
///         \~english Represents parameter collection
class CDbParameterList : public CClrObject
  {
private:
   CDbParameter     *_Parameters[];

protected:
   /// \brief  \~russian Ñîçäàåò ïàðàìåòð êîìàíäû. Âèðòóàëüíûé ìåòîä. Äîëæåí áûòü ïåðåîïðåäåëåí â íàñëåäíèêàõ
   ///         \~english Creates new parameter. Virtual. Must be overriden
   virtual CDbParameter *CreateParameter() { return NULL; }

public:
   /// \brief  \~russian êîíñòðóêòîð êëàññà
   ///         \~english constructor
                     CDbParameterList() { MqlTypeName("CDbParameterList"); }
   /// \brief  \~russian äåñòðóêòîð êëàññà
   ///         \~english destructor
                    ~CDbParameterList();

   // properties

   /// \brief  \~russian Âîçâðàùàåò êîëè÷åñòâî ïàðàìåòðîâ â êîëëåêöèè
   ///         \~english Gets parameters count
   const int Count() { return ArraySize(_Parameters); }

   // methods

   /// \brief  \~russian Âîçâðàùàåò ïàðàìåòð ïî èíäåêñó
   ///         \~english Gets parameter by index
   CDbParameter     *GetByIndex(const int index);
   /// \brief  \~russian Âîçâðàùàåò ïàðàìåòð ïî èìåíè
   ///         \~english Gets parameter by name
   CDbParameter     *GetByName(const string name);

   /// \brief  \~russian Äîáàâëÿåò ïàðàìåòð
   ///         \~english Adds new parameter to the collection
   CDbParameter     *Add(CDbParameter *par);
   /// \brief  \~russian Äîáàâëÿåò ïàðàìåòð
   ///         \~english Creatres and adds new parameter to the collection
   /// \~russian \param name èìÿ ïàðàìåòðà
   /// \~english \param name parameter name
   /// \~russian \param value çíà÷åíèå ïàðàìåòðà
   /// \~english \param value parameter value
   CDbParameter     *Add(const string name,CAdoValue *value);

   /// \brief  \~russian Óäàëÿåò ïàðàìåòð
   ///         \~english Removes the paramer from the collection
   void              Remove(CDbParameter *par);
   /// \brief  \~russian Óäàëÿåò ïàðàìåòð ïî èíäåêñó
   ///         \~english Removes parameter by index
   void              RemoveByIndex(const int index);
   /// \brief  \~russian Óäàëÿåò ïàðàìåòð ïî èìåíè
   ///         \~english Removes parameter by name
   void              RemoveByName(const string name);
  };
//--------------------------------------------------------------------
CDbParameterList::~CDbParameterList(void)
  {
   for(int i=0; i<ArraySize(_Parameters); i++)
      if(CheckPointer(_Parameters[i]))
        {
         delete _Parameters[i];
         _Parameters[i]=NULL;
        }
  }
//--------------------------------------------------------------------
CDbParameter *CDbParameterList::Add(CDbParameter *parameter)
  {
   if(parameter==NULL)
     {
      OnClrException("Add","ArgumentException","");
      return NULL;
     }

   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   DbParameterListAdd(ClrHandle(),parameter.ClrHandle(),exType,exMsg);

   if(exType!="")
     {
      OnClrException("Add",exType,exMsg);
      return NULL;
     }

   int count=Count();
   ArrayResize(_Parameters,count+1);
   _Parameters[count]=parameter;

   return parameter;
  }
//--------------------------------------------------------------------
CDbParameter *CDbParameterList::Add(const string name,CAdoValue *value)
  {
   if(value==NULL)
     {
      OnClrException("Add","ArgumentException","");
      return NULL;
     }

   CDbParameter *par=CreateParameter();
   par.ParameterName(name);
   par.Value(value);
   return Add(par);
  }
//--------------------------------------------------------------------
void CDbParameterList::Remove(CDbParameter *parameter)
  {
   if(parameter==NULL)
     {
      OnClrException("Remove","ArgumentException","");
      return;
     }

   int count = Count();
   int index = -1;
   bool found= false;

   for(int i=0; i<count; i++)
      if(_Parameters[i].ClrHandle()==parameter.ClrHandle())
        {
         index = i;
         found = true;
         break;
        }

   if(!found) return;

   string exType="",exMsg="";
   StringInit(exType,64);
   StringInit(exMsg,256);

   DbParameterListRemove(ClrHandle(),parameter.ClrHandle(),exType,exMsg);

   if(exType!="")
     {
      OnClrException("Remove",exType,exMsg);
      return;
     }

   for(int i=index+1; i<count; i++)
      _Parameters[i-1]=_Parameters[i];

   if(CheckPointer(parameter)==POINTER_DYNAMIC)
     {
      delete parameter;
      parameter=NULL;
     }

   ArrayResize(_Parameters,count-1);

  }
//--------------------------------------------------------------------
void CDbParameterList::RemoveByIndex(const int index)
  {
   if(index>=Count()) return;
   Remove(_Parameters[index]);
  }
//--------------------------------------------------------------------
CDbParameter *CDbParameterList::GetByIndex(const int index)
  {
   if(index>=Count()) return NULL;

   return _Parameters[index];
  }
//--------------------------------------------------------------------
CDbParameter *CDbParameterList::GetByName(const string name)
  {
   for(int i=0; i<Count(); i++)
      if(_Parameters[i].ParameterName()==name)
         return _Parameters[i];

   return NULL;
  }
//--------------------------------------------------------------------
void CDbParameterList::RemoveByName(const string name)
  {
   CDbParameter *par=GetByName(name);
   if(par!=NULL) Remove(par);
  }
//+------------------------------------------------------------------+
