#include "mex.h"
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

int n,m;
int ii,jj,conn;
unsigned char *a,*b,*c;
int *dims;
int ndims;
const int  *vettore;
unsigned char *II,*JJ;
int mp1,np1,np2,mp2;
int cordx1,cordx0;
int cordx,cordxm1,cordxmm,cordxmmm1,cordxpmm1;
int cordxp1,cordxpm,cordxpmp1,cordxmmp1;
unsigned long  *coda;
int lettura;
int scrittura;
int max,v1,v2,v3,v4,v5;
int coda_dim,percentuale;



a=mxGetData(prhs[0]);
b=mxGetData(prhs[1]);
conn=mxGetScalar(prhs[2]);

ndims=2;
vettore = mxGetDimensions(prhs[0]);
n=vettore[0];
m=vettore[1];


dims=mxCalloc(2,sizeof(int));
*(dims)=n+2;
*(dims+1)=m+2;
II= mxCalloc((n+2)*(m+2),sizeof(unsigned char));
JJ= mxCalloc((n+2)*(m+2),sizeof(unsigned char));

percentuale=30;
coda_dim=(n*m*percentuale)%100;
coda_dim=(n*m*percentuale-coda_dim)/100;
coda=mxCalloc(coda_dim,sizeof(unsigned long));


mp1=m+1;
mp2=m+2;
np1=n+1;
np2=n+2;

for (jj=1;jj<mp1;jj++)
    {   for (ii=1;ii<np1;ii++)
        {cordx1=jj*np2+ii;
         cordx0=(jj-1)*n+ii-1;
         *(II+cordx1)=*(a+cordx0);
         *(JJ+cordx1)=*(b+cordx0);
        }
    }

if(conn==8)
{

for (ii=2;ii<np2;ii++)
    {   for (jj=2;jj<mp2;jj++)
        {cordx=(jj-1)*np2+ii-1;
         max=*(JJ+cordx);
         
         v1=*(JJ+cordx-1);
         if(max<v1)
           max=v1;

         v1=*(JJ+cordx-np2);
         if(max<v1)
           max=v1;

         v1=*(JJ+cordx-np2-1); 
         if(max<v1)
           max=v1;

         v1=*(JJ+cordx+np2-1);
         if(max<v1)
           max=v1;

         v1=*(II+cordx);
         if(max>v1)
           max=v1;

        *(JJ+cordx)=max;         
   
        }
    }

lettura=0;
scrittura=0;

for (ii=np1;ii>1;ii--)
    {   for (jj=mp1;jj>1;jj--)
        {cordx=(jj-1)*np2+ii-1;

         cordxp1=cordx+1;
         cordxpm=cordx+np2;
         cordxpmp1=cordxpm+1;
         cordxmmp1=cordx-np2+1;

         max=*(JJ+cordx);
         v1=*(JJ+cordxp1);
         v2=*(JJ+cordxpm);
         v3=*(JJ+cordxmmp1);
         v4=*(JJ+cordxpmp1);
         v5=*(II+cordx);

         if(max<v1)
           max=v1;

         if(max<v2)
           max=v2;
      
         if(max<v3)
          max=v3;

         if(max<v4)
           max=v4;

         if(max>v5)
           max=v5; 

        

        *(JJ+cordx)=max;

       

         

        if ((v2<max)&&(v2<*(II+cordxpm)))
        {*(coda+scrittura)=cordx;
          scrittura=scrittura+1;
        }
        else
            {if ((v1<max)&&(v1<*(II+cordxp1)))
             {*(coda+scrittura)=cordx;
              scrittura=scrittura+1;
             }
             else
                 {if ((v4<max)&&(v4<*(II+cordxpmp1)))
                  {*(coda+scrittura)=cordx;
                   scrittura=scrittura+1;
                  }
                  else
                      {if ((v3<max)&&(v3<*(II+cordxmmp1)))
                       {*(coda+scrittura)=cordx;
                        scrittura=scrittura+1;
                       }
                      }

                 }
            }


       
   
        }
    }


while(lettura<scrittura){

cordx=*(coda+lettura);
lettura++;

cordxm1=cordx-1;
cordxmm=cordx-np2;
cordxmmm1=cordx-np2-1;
cordxpmm1=cordx+np2-1;
cordxp1=cordx+1;
cordxpm=cordx+np2;
cordxpmp1=cordxpm+1;
cordxmmp1=cordx-np2+1;

max=*(JJ+cordx);

v1=*(JJ+cordxmmm1);
if((v1<max)&&(*(II+cordxmmm1)!=v1))
{  if(max<*(II+cordxmmm1))
      *(JJ+cordxmmm1)=max;
   else
      *(JJ+cordxmmm1)=*(II+cordxmmm1);
   *(coda+scrittura)=cordxmmm1;
   scrittura++;
}

v1=*(JJ+cordxm1);
if((v1<max)&&(*(II+cordxm1)!=v1))
{  if(max<*(II+cordxm1))
      *(JJ+cordxm1)=max;
   else
      *(JJ+cordxm1)=*(II+cordxm1);
   *(coda+scrittura)=cordxm1;
   scrittura++;
}

v1=*(JJ+cordxpmm1);
if((v1<max)&&(*(II+cordxpmm1)!=v1))
{  if(max<*(II+cordxpmm1))
      *(JJ+cordxpmm1)=max;
   else
      *(JJ+cordxpmm1)=*(II+cordxpmm1);
   *(coda+scrittura)=cordxpmm1;
   scrittura++;
}

v1=*(JJ+cordxmm);
if((v1<max)&&(*(II+cordxmm)!=v1))
{  if(max<*(II+cordxmm))
      *(JJ+cordxmm)=max;
   else
      *(JJ+cordxmm)=*(II+cordxmm);
   *(coda+scrittura)=cordxmm;
   scrittura++;
}

v1=*(JJ+cordxpm);
if((v1<max)&&(*(II+cordxpm)!=v1))
{  if(max<*(II+cordxpm))
      *(JJ+cordxpm)=max;
   else
      *(JJ+cordxpm)=*(II+cordxpm);
   *(coda+scrittura)=cordxpm;
   scrittura++;
}

v1=*(JJ+cordxmmp1);
if((v1<max)&&(*(II+cordxmmp1)!=v1))
{  if(max<*(II+cordxmmp1))
      *(JJ+cordxmmp1)=max;
   else
      *(JJ+cordxmmp1)=*(II+cordxmmp1);
   *(coda+scrittura)=cordxmmp1;
   scrittura++;
}


v1=*(JJ+cordxp1);
if((v1<max)&&(*(II+cordxp1)!=v1))
{  if(max<*(II+cordxp1))
      *(JJ+cordxp1)=max;
   else
      *(JJ+cordxp1)=*(II+cordxp1);
   *(coda+scrittura)=cordxp1;
   scrittura++;
}

v1=*(JJ+cordxpmp1);
if((v1<max)&&(*(II+cordxpmp1)!=v1))
{  if(max<*(II+cordxpmp1))
      *(JJ+cordxpmp1)=max;
   else
      *(JJ+cordxpmp1)=*(II+cordxpmp1);
   *(coda+scrittura)=cordxpmp1;
   scrittura++;
}

}





}





if(conn==4)
{




for (ii=2;ii<np2;ii++)
    {   for (jj=2;jj<mp2;jj++)
        {cordx=(jj-1)*np2+ii-1;
         max=*(JJ+cordx);
         
         v1=*(JJ+cordx-1);
         if(max<v1)
           max=v1;

         v1=*(JJ+cordx-np2);
         if(max<v1)
           max=v1;


         v1=*(II+cordx);
         if(max>v1)
           max=v1;

        *(JJ+cordx)=max;         
   
        }
    }

lettura=0;
scrittura=0;

for (ii=np1;ii>1;ii--)
    {   for (jj=mp1;jj>1;jj--)
        {cordx=(jj-1)*np2+ii-1;

         cordxp1=cordx+1;
         cordxpm=cordx+np2;
        

         max=*(JJ+cordx);
         v1=*(JJ+cordxp1);
         v2=*(JJ+cordxpm);
      
         v5=*(II+cordx);

         if(max<v1)
           max=v1;

         if(max<v2)
           max=v2;
      
        

         if(max>v5)
           max=v5; 

        

        *(JJ+cordx)=max;

       

         

        if ((v2<max)&&(v2<*(II+cordxpm)))
        {*(coda+scrittura)=cordx;
          scrittura=scrittura+1;
        }
        else
            {if ((v1<max)&&(v1<*(II+cordxp1)))
             {*(coda+scrittura)=cordx;
              scrittura=scrittura+1;
             }
             
                 
            }


       
   
        }
    }


while(lettura<scrittura){

cordx=*(coda+lettura);
lettura++;

cordxm1=cordx-1;
cordxmm=cordx-np2;

cordxp1=cordx+1;
cordxpm=cordx+np2;


max=*(JJ+cordx);



v1=*(JJ+cordxm1);
if((v1<max)&&(*(II+cordxm1)!=v1))
{  if(max<*(II+cordxm1))
      *(JJ+cordxm1)=max;
   else
      *(JJ+cordxm1)=*(II+cordxm1);
   *(coda+scrittura)=cordxm1;
   scrittura++;
}



v1=*(JJ+cordxmm);
if((v1<max)&&(*(II+cordxmm)!=v1))
{  if(max<*(II+cordxmm))
      *(JJ+cordxmm)=max;
   else
      *(JJ+cordxmm)=*(II+cordxmm);
   *(coda+scrittura)=cordxmm;
   scrittura++;
}

v1=*(JJ+cordxpm);
if((v1<max)&&(*(II+cordxpm)!=v1))
{  if(max<*(II+cordxpm))
      *(JJ+cordxpm)=max;
   else
      *(JJ+cordxpm)=*(II+cordxpm);
   *(coda+scrittura)=cordxpm;
   scrittura++;
}




v1=*(JJ+cordxp1);
if((v1<max)&&(*(II+cordxp1)!=v1))
{  if(max<*(II+cordxp1))
      *(JJ+cordxp1)=max;
   else
      *(JJ+cordxp1)=*(II+cordxp1);
   *(coda+scrittura)=cordxp1;
   scrittura++;
}



}

}

*(dims)=n;
*(dims+1)=m;
plhs[0] = mxCreateNumericArray(ndims,dims,mxUINT8_CLASS,mxREAL);
c=mxGetData(plhs[0]);
for (jj=1;jj<mp1;jj++)
    {   for (ii=1;ii<np1;ii++)
        {cordx1=jj*np2+ii;
         cordx0=(jj-1)*n+ii-1;
         *(c+cordx0)=*(JJ+cordx1);
        }
    }

mxFree(II);
mxFree(JJ);
mxFree(coda);


	 
}

	 
