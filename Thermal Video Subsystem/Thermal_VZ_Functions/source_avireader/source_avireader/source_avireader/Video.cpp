#include "Video.h"



CVideo::CVideo(void)
{
	//initialisation
	this->Init();
}

CVideo::~CVideo(void)
{
 	this->CloseVideo();
	AVIFileExit();	// releases AVIFile library 
}

void CVideo::Init(void)
{
	//initialisation COM
	//CoInitialize(NULL);
	
	AVIFileInit();	// opens AVIFile library 

	m_pFile = NULL;
	m_pGetFrame = NULL;
	m_pAviStream = NULL;

	m_iWidth = 0; 
	m_iHeight = 0;
	m_iNbImages = 0;
	m_iRate = 0;
	m_iSizeImageData = 0;
	m_FourCC = 0;


}


void CVideo::CloseVideo(void)
{

	if(m_pGetFrame)
		AVIStreamGetFrameClose(m_pGetFrame);	// releases resources used to decompress video frames.
	if(m_pAviStream)
		AVIStreamRelease(m_pAviStream);	// closes the stream
	if(m_pFile)
		AVIFileRelease(m_pFile);  // closes the file

	m_pFile = NULL;
	m_pAviStream = NULL;
	m_pGetFrame = NULL;

}


BOOL CVideo::OpenVideo(const char* strFichier)
{
	if( IsOpen() ) this->CloseVideo();


	//Open video File
    int res = AVIFileOpen(&m_pFile, strFichier, OF_SHARE_DENY_NONE, NULL);

    if(res != AVIERR_OK)
    {
        //an error occures
        if (m_pFile!=NULL)
		{
            AVIFileRelease(m_pFile);
			m_pFile = NULL;
		}
        
        return FALSE;
    }


	AVIFILEINFO avi_info;
    AVIFileInfo(m_pFile, &avi_info, sizeof(AVIFILEINFO));
		
	//On récupère les informations concernant la vidéo
	m_iRate = (avi_info.dwRate / avi_info.dwScale);
	m_iNbImages = avi_info.dwLength;
	m_iWidth = avi_info.dwWidth;
	m_iHeight = avi_info.dwHeight;
	m_iSizeImageData = m_iWidth*m_iHeight*3;

	
    
	// Open the streams
    res = AVIFileGetStream(m_pFile, &m_pAviStream, streamtypeVIDEO /*video stream*/, 0 /*first stream*/);
	if(res != AVIERR_OK)
    {
        if (m_pAviStream != NULL)
		{        
			AVIStreamRelease(m_pAviStream);
			m_pAviStream = NULL;
		}
        
        return FALSE;
    }

	AVISTREAMINFO avi_info2;
	AVIStreamInfo(m_pAviStream,&avi_info2,sizeof(AVISTREAMINFO));
	m_FourCC = avi_info2.fccHandler;
	

	//décompression
	m_pGetFrame = AVIStreamGetFrameOpen(m_pAviStream,NULL);

	if( m_pGetFrame == NULL ) return FALSE;
	


	return TRUE;
}


int CVideo::GetSizeImagedata() const
{
	return m_iSizeImageData;
}

int CVideo::GetWidth() const
{
	return m_iWidth;
}


int CVideo::GetHeight() const
{
	return m_iHeight;
}


int CVideo::memcopy_without_padding(unsigned char* pDataRGB, const unsigned char* pDIB, int iSize) const
{
	int iIndexRGB = 0;
	int iIndexDIB = 0;

	// Every row have a multiple of 4 BYTE 
	char tabPadding[4] = {0,3,2,1};
	unsigned char nbPadding = tabPadding[(3*m_iWidth)%4];

	if(nbPadding == 0)
	{	
		memcpy(pDataRGB, pDIB, iSize);
		return iSize;
	}
	else
	{

		if(pDataRGB)
		{			
			for(int j=0; j<m_iHeight; j++) 
			{
				for(int i=0; i<m_iWidth*3; i++) 
				{
					pDataRGB[iIndexRGB] = pDIB[iIndexDIB];
					iIndexRGB++;
					iIndexDIB++;
				}
				iIndexDIB += nbPadding;
			}
		}
	}
	return iIndexDIB;
}




unsigned char* CVideo::GetDataImage(int iNumImage) const
{
	unsigned char* pDataImageRGB = NULL;

	if((iNumImage<m_iNbImages) && m_pGetFrame)
	{
		unsigned char* pDIB = (unsigned char*)AVIStreamGetFrame(m_pGetFrame, iNumImage);


		//get the BitmapInfoHeader
		BITMAPINFOHEADER BmpInfo;
		memcpy(&BmpInfo.biSize, pDIB, sizeof(BITMAPINFOHEADER));

		if (BmpInfo.biSizeImage < 1)
		{
			return NULL;
		}

		pDataImageRGB = new unsigned char[GetSizeImagedata()];
		//now get the bitmap bits
		int iSize = memcopy_without_padding(pDataImageRGB, pDIB + sizeof(BITMAPINFOHEADER), BmpInfo.biSizeImage);

		if( iSize != BmpInfo.biSizeImage)
		{
			delete pDataImageRGB;
			return NULL;
		}

		//TransformDIB2MatlabData(pDataImageRGB, pDataBGR);
	}

	return pDataImageRGB;
}


void CVideo::GetDataImage(unsigned char* pDataImageRGB, int iNumImage) const
{


	if((iNumImage<m_iNbImages) && IsOpen())
	{
		unsigned char* pDIB = (unsigned char*)AVIStreamGetFrame(m_pGetFrame,iNumImage);

		//get the BitmapInfoHeader
		BITMAPINFOHEADER BmpInfo;
		memcpy(&BmpInfo.biSize, pDIB, sizeof(BITMAPINFOHEADER));

		unsigned char* pDataBGR = new unsigned char[GetSizeImagedata()];

		int iSize = memcopy_without_padding(pDataBGR, pDIB + sizeof(BITMAPINFOHEADER), BmpInfo.biSizeImage);

		TransformDIB2MatlabData(pDataImageRGB, pDataBGR);

		delete pDataBGR;		
	}
}

/*
CImg* CVideo::GetImage(int iNumImage) const
{
	CImg* pImage = NULL;

	if(this->IsOpen())
	{
		//ouverture de l'image
		unsigned char* pDataImage = this->GetDataImage(iNumImage);

		//création
		pImage = new CImg(pDataImage,m_iWidth,m_iHeight);


		//destruction
		delete pDataImage;
	}

	return pImage;
}
*/

//*****************************************************************************
// Sommaire:	Transform DIB image data to matlab image data.
//
//		pDataBmpBGR describes the image, pixel by pixel in DIB format.
//		Pixels are stored "upside-down" with respect to normal image raster scan order, 
//		starting in the lower left corner, going from left to right, and then row by row 
//		from the bottom to the top of the image.
//		Each pixel is coded on 3 values (uint8) with sequence Blue Green Red
//
//		pDataMatlab describes the image, pixel by pixel in matlab format 
//		Pixels are stored starting in the uper left corner, cols by cols going from top to bottom,
//		and then from the left to the right of the image. 
//		Each pixel is coded on 3 values (uint8) with sequence Red Green Blue
//
//		If we have an image IM width = 3 pixels(Pix) and height = 2 pixels(Pix)
//
//		IM = [PixD PixE PixF]
//			 [PixA PixB PixC]
//
//		pDataBmpBGR[] = [Ba Ga Ra Bb Gb Rb Bc Gc Rc Bd Gd Rd Be Ge Re Bf Gf Rf]    
//		
//		pDataMatlab[] = [Rd Ra Re Rb Rf Rc Gd Ga Ge Gb Gf Gc Bd Ba Be Bb Bf Bc]
//
//****************************************************************************
void CVideo::TransformDIB2MatlabData(unsigned char* pDataMatlab, const unsigned char* pDataBmpBGR) const
{


	int iOffsetR = 0;
	int iOffsetG = m_iWidth*m_iHeight;
	int iOffsetB = m_iWidth*m_iHeight*2;

	int iIndex = 0;

	for(int i=0; i<m_iWidth; i++)
	{
		for(int j=(m_iHeight-1); 0<=j; j--)
		{
			//Affectation Red
			pDataMatlab[iOffsetR + iIndex] = pDataBmpBGR[i*3 + 2 + j*m_iWidth*3];

			//Affectation Green
			pDataMatlab[iOffsetG + iIndex] = pDataBmpBGR[i*3 + 1 + j*m_iWidth*3];

			//Affectation Blue
			pDataMatlab[iOffsetB + iIndex] = pDataBmpBGR[i*3 + 0 + j*m_iWidth*3];

			iIndex++;
		}
	}		
}


BOOL CVideo::IsOpen(void) const
{	
	//retourne si vidéo ouverte
	return (m_pFile!=NULL);
}


char* CVideo::GetCodec(void) const
{
	char* strCodec = new char[5];

	int iFourCC = m_FourCC;

	for(int i=0; i<4; i++)
	{		
		strCodec[i] = (0xFF & iFourCC);
		iFourCC = (iFourCC>>8);
	}
	strCodec[4] = 0;

	return strCodec;
}