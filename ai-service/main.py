#!/usr/bin/env python3
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import cv2
import numpy as np
import mediapipe as mp
import pytesseract
from PIL import Image
import io
import json
import re
from typing import List, Dict, Any

app = FastAPI(title="Family Ties AI Service")

# MediaPipe Initialization
mp_face = mp.solutions.face_mesh
mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils

@app.post("/process/face")
async def process_face(image: UploadFile = File(...)):
    """Extract 468 face landmarks from uploaded image"""
    try:
        contents = await image.read()
        np_img = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
        
        with mp_face.FaceMesh(static_image_mode=True, max_num_faces=1) as face_mesh:
            results = face_mesh.process(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
            
            if not results.multi_face_landmarks:
                raise HTTPException(status_code=400, detail="No face detected")
            
            landmarks = []
            for face_landmarks in results.multi_face_landmarks:
                for lm in face_landmarks.landmark:
                    landmarks.append({
                        'x': lm.x,
                        'y': lm.y,
                        'z': lm.z
                    })
            
            return JSONResponse({
                'success': True,
                'landmarks': landmarks,
                'count': len(landmarks)
            })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/process/hand")
async def process_hand(image: UploadFile = File(...)):
    """Extract 21 hand landmarks"""
    try:
        contents = await image.read()
        np_img = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(np_img, cv2.IMREAD_COLOR)
        
        with mp_hands.Hands(static_image_mode=True, max_num_hands=2) as hands:
            results = hands.process(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
            
            if not results.multi_hand_landmarks:
                raise HTTPException(status_code=400, detail="No hand detected")
            
            hand_data = []
            for hand_landmarks in results.multi_hand_landmarks:
                landmarks = []
                for lm in hand_landmarks.landmark:
                    landmarks.append({'x': lm.x, 'y': lm.y, 'z': lm.z})
                hand_data.append(landmarks)
            
            # Calculate 2D:4D ratio
            ratio = None
            if hand_data:
                ratio = calculate_2d_4d(hand_data[0])
            
            return JSONResponse({
                'success': True,
                'hands': hand_data,
                'ratio_2d_4d': ratio
            })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def calculate_2d_4d(landmarks):
    """Calculate 2D:4D digit ratio from hand landmarks"""
    INDEX_TIP = 8
    INDEX_PIP = 6
    RING_TIP = 12
    RING_PIP = 10
    
    def distance(lm1, lm2):
        return np.sqrt((lm1.x - lm2.x)**2 + (lm1.y - lm2.y)**2 + (lm1.z - lm2.z)**2)
    
    index_len = distance(landmarks[INDEX_TIP], landmarks[INDEX_PIP])
    ring_len = distance(landmarks[RING_TIP], landmarks[RING_PIP])
    
    return index_len / ring_len if ring_len > 0 else None

@app.post("/process/scanner")
async def scan_family_tree(image: UploadFile = File(...)):
    """OCR + layout analysis for family tree images"""
    try:
        contents = await image.read()
        img = Image.open(io.BytesIO(contents))
        
        if img.mode != 'RGB':
            img = img.convert('RGB')
        
        # Run OCR
        ocr_text = pytesseract.image_to_string(img, config='--psm 6')
        
        # Extract names
        names = re.findall(r'[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*', ocr_text)
        unique_names = list(set(names))
        
        # Layout analysis
        np_img = np.array(img)
        gray = cv2.cvtColor(np_img, cv2.COLOR_RGB2GRAY)
        _, binary = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY)
        
        contours, _ = cv2.findContours(binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        boxes = []
        for cnt in contours:
            x, y, w, h = cv2.boundingRect(cnt)
            if w > 30 and h > 15 and w < 200 and h < 60:
                boxes.append({'x': x, 'y': y, 'width': w, 'height': h})
        
        return JSONResponse({
            'success': True,
            'ocr_text': ocr_text,
            'extracted_names': unique_names,
            'boxes': boxes,
            'confidence': 0.85
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=5000)
