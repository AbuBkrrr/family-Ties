# Family Ties - Digital Legacy Platform

**Building heritage through technology**

Family Ties is a full-stack family connectivity and digital legacy platform featuring AI digital twins, family tree management, biometric trait collection, and post-death revelations.

## Features

- **Trait Collection**: Face recognition, hand scanning, height estimation (MediaPipe)
- **Family Tree**: Auto-generated tree, paper tree scanner (OCR + OpenCV)
- **AI Digital Twin**: LLM fine-tuning, voice cloning, trained on digital footprints
- **Death Confirmation**: 5-member verification before AI activation
- **Post-Death Revelations**: Wills, gifts, secrets released after death (non-monetary)
- **Social Media Import**: Facebook, Twitter, Instagram, email import for AI training
- **Daily AI Training**: Selfies, journal entries, voice recordings
- **Messaging**: Group chat, one-to-one private chat (E2EE)
- **Competitions**: Recognition-based competitions (no money)
- **Family Photo Album**: Shared photo/video storage

## Tech Stack

### Frontend
- React + React Native (mobile)
- Tailwind CSS

### Backend
- Node.js + Express
- PostgreSQL
- Redis (job queue)

### AI Microservice
- Python (FastAPI)
- OpenCV, MediaPipe, Tesseract OCR

### Storage & External Services
- AWS S3 + IPFS
- OpenAI (LLM fine-tuning)
- ElevenLabs (Voice cloning)

## Project Structure

```
family-ties/
├── backend/
│   ├── routes/
│   ├── middleware/
│   ├── services/
│   ├── models/
│   ├── migrations/
│   ├── config/
│   └── server.js
├── ai-service/
│   ├── routes/
│   ├── services/
│   ├── models/
│   └── main.py
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── contexts/
│   │   └── App.js
│   └── package.json
├── docker-compose.yml
├── .env.example
└── README.md
```

## Quick Start

### Prerequisites
- Node.js 16+
- Python 3.9+
- PostgreSQL 13+
- Redis 7+
- Docker & Docker Compose (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AbuBkrrr/family-Ties.git
   cd family-Ties
   ```

2. **Setup environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Start with Docker Compose**
   ```bash
   docker-compose up -d
   ```

4. **Run migrations**
   ```bash
   docker-compose exec backend npm run migrate
   ```

5. **Access the application**
   - Frontend: http://localhost:8080
   - Backend API: http://localhost:3000/api
   - AI Service: http://localhost:5000

### Manual Setup

#### Backend
```bash
cd backend
npm install
npm run migrate
npm run dev
```

#### AI Microservice
```bash
cd ai-service
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python main.py
```

#### Frontend
```bash
cd frontend
npm install
npm start
```

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh JWT token

### User Management
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile
- `GET /api/users/family` - Get family information

### Biometrics
- `POST /api/biometrics/face` - Upload face data
- `POST /api/biometrics/hand` - Upload hand data
- `POST /api/biometrics/height` - Record height
- `POST /api/relatives/match` - Find matching relatives

### Family Tree
- `GET /api/tree/view` - View family tree
- `POST /api/tree/add-relative` - Add family member
- `PUT /api/tree/relationship` - Update relationship

### Scanner
- `POST /api/scanner/upload` - Upload paper tree image
- `GET /api/scanner/status/:jobId` - Check scanning progress
- `POST /api/scanner/import` - Import scanned tree

### AI Twin
- `POST /api/ai/train` - Start AI training
- `GET /api/ai/status` - Get training status
- `POST /api/ai/chat` - Chat with AI twin
- `POST /api/death/confirm` - Confirm member death

### Messaging
- `POST /api/messages/private` - Send private message
- `POST /api/messages/group` - Send group message
- `GET /api/messages/:chatId` - Get chat history

### Competitions
- `GET /api/competitions` - List competitions
- `POST /api/competitions/:compId/join` - Join competition
- `POST /api/competitions/:entryId/submit` - Submit entry

## Security Features

- JWT-based authentication
- Bcrypt password hashing
- End-to-end encryption for private messages
- Biometric data stored encrypted (raw images never stored)
- Rate limiting on sensitive endpoints
- CORS configured for security
- Helmet security headers
- Input validation and sanitization

## Important Constraints

- ✅ No financial features (no wallet, marketplace, or coins)
- ✅ All biometric data processed on-device, only vectors stored
- ✅ Death confirmation requires 5+ family members
- ✅ AI twin uses LLM fine-tuning + voice cloning
- ✅ Paper scanner uses Tesseract OCR + OpenCV layout analysis

## Database

### Key Tables
- `users` - User accounts
- `families` - Family groups
- `houses` - Geographic sub-clans
- `person_details` - Biographical information
- `family_relationships` - Family connections
- `biometric_traits` - Encrypted biometric vectors
- `ai_training_data` - Data sources for AI training
- `ai_twin_models` - Trained AI models
- `private_messages` - E2EE encrypted messages
- `group_messages` - Family/house group chat
- `death_revelations` - Post-death content
- `paper_tree_scans` - OCR results from paper trees
- `competitions` - Family competitions

## Contributing

1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Ensure all tests pass

## License

MIT

## Support

For issues and questions, please open a GitHub issue.
