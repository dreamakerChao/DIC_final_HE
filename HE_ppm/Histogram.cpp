

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
// #include <iostream>


#define Chnlno 3  /* RGB 3 channels */
#define Hlen 1600
#define HE_long 256

#define wide  720  //720
#define line  480  //480

FILE *fpi, *fper;

void ReadNSaveAPixel2LB(float*, int, int);	//read yuv out
void OutputAPixel2panel(float *, int, int);

//void Change_Y_value(float *,int,int,int,int,float);

int main()
{
	//�ŧi
	int i, j, tmp;
	long Num;

	long Histogram[HE_long]; // 256 302400
	float Prob[HE_long];

	float Abuf[Hlen+4][Chnlno];
	float *pA, Pr;

	char current_file_name[256],output_file_name[256],strtmp[20];


	strcpy(current_file_name,"picture/EX.ppm");
	strcpy(output_file_name,"picture/EXHE.ppm");

	//reset the value
	for (i=0;i<Hlen;i++)	
		for (j=0;j<Chnlno;j++)
			Abuf[i][j]=0;

	for (i=0;i<HE_long;i++)
	{
		Histogram[i]=0;
		Prob[i]=0;
	}
	
	pA = Abuf[0];

	fpi  = fopen (current_file_name, "r");

	for(i=0;i<4;i++)	//CLEAR THE TAG
		fscanf(fpi,"%s\n",strtmp);	
	
	//�Ĥ@��Ū�JPPM��, ���R�ӹ�Histogram���G
	for (i=0;i<line;i++)
	{	
		for (j=0;j<wide;j++)//get one line
		{
			ReadNSaveAPixel2LB(pA, j, 0); //ppm

			tmp = (int) *(pA+j*Chnlno+0);	//compute the histogram

			Histogram[tmp]=Histogram[tmp]+1;
		}
	}
	

	//�p��ӹ�Histogram���v����

	Num=wide*line; //here is 720*480
	//compute the total Histogram probability
	
	Pr=((float)Histogram[0]/ (float)Num);
	
	for (i=1;i<HE_long;i++)	//1-256
	{		
		Pr=((float)Histogram[i]/ (float)Num);
		Prob[i]=Prob[i-1]+Pr;
	}

	//���sŪ�J�ӹϨåB��XUniform Hisgram
	fpi  = fopen (current_file_name, "r"); //reopen file
	fper = fopen (output_file_name, "w");	//open output file

	fprintf(fper,"P3\n");
	fprintf(fper,"720 480\n");
	fprintf(fper,"255\n");

	for(i=0;i<4;i++)	//CLEAR THE TAG
		fscanf(fpi,"%s\n",strtmp);

	for (i=0;i<line;i++)
		for (j=0;j<wide;j++)//get one line
		{
			ReadNSaveAPixel2LB(pA, j, 0); //conv rgb to yuv

			tmp = (int) *(pA+j*Chnlno+0);	//mapping the input Y to uniform Yout
			*(pA+j*Chnlno+0) = 255*Prob[tmp];
			
			OutputAPixel2panel(pA, j, 0); //conv yuv to rgb and write

		}

	fclose(fpi);
	fclose(fper);
}

void ReadNSaveAPixel2LB(float *pLB, int x, int bm)
{	unsigned char rr, gg, bb;
    float frr, fgg, fbb, y, u, v;
    int irr, igg, ibb;

	if (bm==0)
	{   
		fscanf(fpi,"%d%d%d",&irr,&igg,&ibb);
    	rr = irr; gg = igg; bb = ibb;
	} 
	else 
	{
/*		fscanf(fpi,"%x%x%x",rr,gg,bb);
*/
		bb=fgetc(fpi);
		gg=fgetc(fpi);
		rr=fgetc(fpi);

/*
		printf("%x %x %x   ", rr, gg, bb);
*/	}
    frr= (float) rr; fgg= (float) gg; fbb= (float) bb;
/*	printf("%f %f %f   ", frr, fgg, fbb);
*/
	y = 0.299*frr + 0.587*fgg + 0.114*fbb;
  	v = 0.5*frr  - 0.419*fgg - 0.081*fbb +128.0;
	u =-0.169*frr - 0.331*fgg + 0.5*fbb +128.0;

    *(pLB+x*Chnlno+0)= y; *(pLB+x*Chnlno+1)= u; *(pLB+x*Chnlno+2)= v;
}

void OutputAPixel2panel(float *pLB, int x, int bm)
{	
	float y, u, v;
	unsigned char rr, gg, bb;

 	y= *(pLB+x*Chnlno+0);
    u= *(pLB+x*Chnlno+1);
    v= *(pLB+x*Chnlno+2);


	if ((y+1.375*(v-128))<0)    {	rr=0;	}
	else if ((y+1.375*(v-128))>255)    {	rr=255;	}	else
	rr= (int) (y+1.375*(v-128));						/*1.371*/
    if ((y - 0.703125*(v-128) - 0.34375*(u-128))<0)    {	gg=0;	}
	else if ((y - 0.703125*(v-128) - 0.34375*(u-128))>255)    {	gg=255;	} else
	gg= (int) (y - 0.703125*(v-128) - 0.34375*(u-128));		/*y - 0.698*v - 0.336*u*/
    if ((y + 1.75*(u-128.0))<0)    {	bb=0;	}
	else if ((y + 1.75*(u-128.0))>255)    {	bb=255;	}	else
	bb= (int) (y + 1.75*(u-128.0));						/*y + 1.732*u*/

	if (bm==0)	fprintf(fper,"%3d %3d %3d ",rr,gg,bb);	//output file
	else		fprintf(fper,"%c%c%c",bb,gg,rr);
/*	printf("%x %x %x   \n",rr,gg,bb);
	getch();
*/
}