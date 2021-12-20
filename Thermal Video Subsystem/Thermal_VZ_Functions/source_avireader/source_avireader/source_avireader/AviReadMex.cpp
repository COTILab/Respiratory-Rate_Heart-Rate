#include <mex.h>
#include "Video.h"

#define NUMBER_OF_FIELDS 2


//****************************************************************
// Param1:  prhs[0]  File name
// Param2:	prhs[1]  Matrix of frame's numbers
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
	int iNbFrame;
	double* pMatNumFrame = NULL;
	mxArray* pMat = NULL;

	/* Check proper input and output */
	
	if (nrhs < 1)
		mexErrMsgTxt("One input required.");
	else if (nlhs > 2)
		mexErrMsgTxt("Too many output arguments.");
	
	/* Input must be a string. */
	if (mxIsChar(prhs[0]) != 1)
		mexErrMsgTxt("Input must be a string.");

	if (nrhs == 2)
	{	
		/* Input must be a row vector. */
		if( !mxIsDouble(prhs[1]) || mxIsComplex(prhs[1]) || (mxGetM(prhs[1]) != 1) )
			mexErrMsgTxt("Input must be a double row vector.");

		iNbFrame = mxGetN(prhs[1]);

		//Create a pointer to the input matrix
		pMatNumFrame = mxGetPr(prhs[1]);
	}
	else
	{
		iNbFrame = 1;
		pMat = mxCreateDoubleMatrix(1, 1, mxREAL);
		pMatNumFrame = mxGetPr(pMat);
		pMatNumFrame[0] = 1;
	}
	


	//*****************************************************
	// Ouvre la video
	CVideo AviVideo;

	if( !AviVideo.OpenVideo(mxArrayToString(prhs[0])) )
	{
		char strErr[100];

		char* sCodec = AviVideo.GetCodec();		
		sprintf(strErr, "Problem while opening Avi file. codec %s not found\n", sCodec );
		delete sCodec;
		AviVideo.CloseVideo();
		mexErrMsgTxt(strErr);
	}




	//******************************************************
	//Creation of the structure 1*iNbFrame
	// with fields		.cdata
	//					.colormap
	int dimStruct[2] = {1,iNbFrame};
	const char *field_names[] = {"cdata", "colormap"};

	plhs[0] = mxCreateStructArray(2, dimStruct, NUMBER_OF_FIELDS, field_names);

	//Get num index of fields
	int cdata_field = mxGetFieldNumber(plhs[0],"cdata");
	int colormap_field = mxGetFieldNumber(plhs[0],"colormap");



	//******************************************************
	// For each images 
	// assign the fields	.cdata
	//						.colormap
	int dimsIm[3]; //Array for image size
	dimsIm[0]=AviVideo.GetHeight(); 
	dimsIm[1]=AviVideo.GetWidth(); 
	dimsIm[2]=3; 
						
	for(int i=0; i<iNbFrame; i++)
	{
		mxArray* pMxIm = mxCreateNumericArray(3,dimsIm,mxUINT8_CLASS,mxREAL);

		//Get image
		int iNumFrame = pMatNumFrame[i];
		AviVideo.GetDataImage( ((unsigned char*)mxGetPr(pMxIm)), iNumFrame);
		

		//Set image to the struct
		mxSetFieldByNumber(plhs[0], i, cdata_field, pMxIm);		
	}

	AviVideo.CloseVideo();

}