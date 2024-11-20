from flask import request, jsonify
from flask_restful import Resource
from datetime import datetime
from db_models.models import db, Chemical, User, PI, Building, Room, Space

from flask import request, jsonify
from flask_restful import Resource
from werkzeug.security import check_password_hash
from db_models.models import db, User, PI, Room, Building

class CheckChemical(Resource):
    def post(self):
        try:
            # Parse request data
            data = request.get_json()
            barcode = data.get('barcode')
            selected_room_id = data.get('selected_room_id')

            if not barcode or not selected_room_id:
                print("DEBUG: Missing barcode or selected_room_id in request")
                return {"error": "barcode and selected_room_id are required"}, 400

            print(f"DEBUG: Received barcode: {barcode}, selected_room_id: {selected_room_id}")

            # Query chemical by barcode
            chemical = Chemical.query.filter_by(barcode=barcode).first()

            if not chemical:
                print(f"DEBUG: Chemical with barcode {barcode} not found")
                return {"alert": "Sorry, that chemical is not found"}, 404

            print(f"DEBUG: Found chemical: {chemical}")

            # Fetch the associated Room
            room = Room.query.get(chemical.room_id)
            if not room:
                print(f"DEBUG: Room with ID {chemical.room_id} not found")
                return {"error": "Room not found for this chemical"}, 404

            # Fetch the associated Building
            building = Building.query.get(room.building_id)
            building_name = building.name if building else "Unknown Building"

            # Fetch the associated Space
            space = chemical.space
            space_description = space.description if space else None

            # Check if the room matches
            if chemical.room_id != selected_room_id:
                print(f"DEBUG: Room mismatch for chemical. Expected {selected_room_id}, found {chemical.room_id}")
                room_number = room.room_number if room else "Unknown Room"
                return {
                    "alert": f"Please return this chemical to {room_number}, {building_name} {space_description or ''}".strip()
                }, 200

            # Chemical matches the room
            print(f"DEBUG: Chemical is in the correct room: {selected_room_id}")
            response_data = {
                "chemical_info": {
                    "name": chemical.name,
                    "cas_number": chemical.cas_number,
                    "barcode": chemical.barcode,
                    "amount": chemical.amount,
                    "unit": chemical.unit,
                    "expiration_date": chemical.expiration_date.strftime('%Y-%m-%d') if chemical.expiration_date else "N/A",
                    "room": f"{room.room_number}, {building_name}",
                    "space": space_description or ""
                }
            }
            print(f"DEBUG: Returning chemical info: {response_data}")
            return response_data, 200

        except Exception as e:
            print(f"ERROR: Exception occurred - {str(e)}")
            return {"error": f"Internal server error: {str(e)}"}, 500





# --- Login Route ---
class LoginResource(Resource):
    def post(self):
        data = request.get_json()
        email = data.get('email')
        password = data.get('password')

        # Validate user credentials
        user = User.query.filter_by(email=email).first()
        if user and user.check_password(password):
            # Fetch PIs and associated room/building details
            pi_data = []
            for pi in user.pis:
                rooms = Room.query.filter_by(pi_id=pi.id).all()
                room_data = [
                    {
                        "room_id": room.id,
                        "room_number": room.room_number,
                        "building_name": Building.query.get(room.building_id).name
                    }
                    for room in rooms
                ]
                pi_data.append({
                    "pi_id": pi.id,
                    "pi_name": pi.name,
                    "rooms": room_data
                })

            return jsonify({
                "success": True,
                "user_name": user.name,
                "pis": pi_data
            })

        return jsonify({"success": False, "message": "Invalid email or password"}), 401


# --- Routes for Chemicals ---
class ChemicalListResource(Resource):
    def get(self):
        chemicals = Chemical.query.all()
        return jsonify([{
            'id': chem.id,
            'name': chem.name,
            'barcode': chem.barcode,
            'amount': chem.amount,
            'unit': chem.unit,
            'total_weight_lbs': chem.total_weight_lbs,
            'room': chem.room.room_number if chem.room else None,  # Room information
            'space': chem.space.description if chem.space else None  # Space information
        } for chem in chemicals])

    def post(self):
        data = request.get_json()

        expiration_date = data.get('expiration_date')
        if expiration_date:
            expiration_date = datetime.strptime(expiration_date, '%Y-%m-%d').date()
        
        new_chemical = Chemical(
            name=data['name'],
            cas_number=data['cas_number'],
            room_id=data['room_id'],
            space_id=data.get('space_id'),  # Optional
            amount=data['amount'],
            unit=data['unit'],
            expiration_date=expiration_date,
            total_weight_lbs=data['total_weight_lbs']
        )
        db.session.add(new_chemical)
        db.session.commit()
        return jsonify({'id': new_chemical.id, 'barcode': new_chemical.barcode})

# --- Route to find chemicals by name, barcode, or CAS number ---
class ChemicalQueryResource(Resource):
    def get(self):
        # Extracting query parameters
        name = request.args.get('name')
        barcode = request.args.get('barcode')
        cas_number = request.args.get('cas_number')
        
        query = Chemical.query
        if name:
            query = query.filter_by(name=name)
        if barcode:
            query = query.filter_by(barcode=barcode)
        if cas_number:
            query = query.filter_by(cas_number=cas_number)
        
        chemicals = query.all()
        return jsonify([{
            'id': chem.id,
            'name': chem.name,
            'barcode': chem.barcode,
            'amount': chem.amount,
            'unit': chem.unit,
            'total_weight_lbs': chem.total_weight_lbs,
            'room': chem.room.room_number if chem.room else None,  # Room information
            'space': chem.space.description if chem.space else None  # Space information
        } for chem in chemicals])

# --- Route to find PIs associated with a user ---
class UserPIResource(Resource):
    def get(self, user_id):
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404

        pis = user.pis
        return jsonify([{
            'id': pi.id,
            'name': pi.name,
            'email': pi.email,
            'rooms': [{'id': room.id, 'room_number': room.room_number} for room in pi.rooms]  # PI's rooms
        } for pi in pis])

# --- Route to create Users ---
class UserResource(Resource):
    def post(self):
        data = request.get_json()
        new_user = User(
            name=data['name'],
            email=data['email'],
            password=data['password']
        )
        db.session.add(new_user)
        db.session.commit()
        return jsonify({'id': new_user.id, 'name': new_user.name})
    
# --- Route to associate a PI with a User ---
class UserPIAssociationResource(Resource):
    def post(self, user_id, pi_id):
        user = User.query.get(user_id)
        pi = PI.query.get(pi_id)

        if not user or not pi:
            return jsonify({'error': 'User or PI not found'}), 404

        # Associate PI with the User (many-to-many relationship)
        user.pis.append(pi)
        db.session.commit()

        return jsonify({'message': f'PI {pi.name} associated with User {user.name}'})

    def delete(self, user_id, pi_id):
        user = User.query.get(user_id)
        pi = PI.query.get(pi_id)

        if not user or not pi:
            return jsonify({'error': 'User or PI not found'}), 404

        # Remove association between PI and User
        user.pis.remove(pi)
        db.session.commit()

        return jsonify({'message': f'PI {pi.name} removed from User {user.name}'})

# --- Route to create PIs ---
class PIResource(Resource):
    def post(self):
        data = request.get_json()
        new_pi = PI(
            name=data['name'],
            email=data['email'],
            password=data['password']
        )
        db.session.add(new_pi)
        db.session.commit()
        return jsonify({'id': new_pi.id, 'name': new_pi.name})
    
# --- Route to get all PIs ---
class PIListResource(Resource):
    def get(self):
        pis = PI.query.all()
        return jsonify([{
            'id': pi.id,
            'name': pi.name,
            'email': pi.email,
            'rooms': [{'id': room.id, 'room_number': room.room_number} for room in pi.rooms]
        } for pi in pis])

# --- Route to get all Users ---
class UserListResource(Resource):
    def get(self):
        users = User.query.all()
        return jsonify([{
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'pis': [{'id': pi.id, 'name': pi.name} for pi in user.pis]  # PIs the user is associated with
        } for user in users])


# --- Route to create Buildings ---
class BuildingResource(Resource):
    def post(self):
        data = request.get_json()
        new_building = Building(
            name=data['name']
        )
        db.session.add(new_building)
        db.session.commit()
        return jsonify({'id': new_building.id, 'name': new_building.name})

# --- Route to create Rooms ---
class RoomResource(Resource):
    def post(self):
        data = request.get_json()
        new_room = Room(
            building_id=data['building_id'],
            room_number=data['room_number'],
            pi_id=data['pi_id'],
            contact_name=data.get('contact_name'),  # Optional
            contact_phone=data.get('contact_phone')  # Optional
        )
        db.session.add(new_room)
        db.session.commit()
        return jsonify({'id': new_room.id, 'room_number': new_room.room_number})

# --- Route to create Spaces ---
class SpaceResource(Resource):
    def post(self):
        data = request.get_json()
        new_space = Space(
            room_id=data['room_id'],
            description=data['description'],
            space_type=data.get('space_type'),  # Optional
            space_id=data.get('space_id')  # Optional
        )
        db.session.add(new_space)
        db.session.commit()
        return jsonify({'id': new_space.id, 'description': new_space.description})

class ChemicalsByRoom(Resource):
    """
    RESTful resource to handle retrieving chemicals by room ID.
    """

    def get(self, room_id):
        """
        Retrieve a list of chemicals associated with the given room_id.
        """
        try:
            # Query the database for chemicals with the specified room_id
            chemicals = Chemical.query.filter_by(room_id=room_id).all()

            if not chemicals:
                return {"message": "No chemicals found for the given room ID"}, 404

            # Format the response
            chemical_list = [
                {
                    "room_id": chemical.room_id,
                    "barcode": chemical.barcode,
                    "name": chemical.name
                }
                for chemical in chemicals
            ]

            return {"chemicals": chemical_list}, 200

        except Exception as e:
            return {"error": str(e)}, 500


# --- Add the new routes to your app ---
def initialize_routes(api):
    api.add_resource(CheckChemical, '/scan/check_chemical')
    api.add_resource(LoginResource, '/login')
    api.add_resource(ChemicalListResource, '/chemicals')
    api.add_resource(ChemicalQueryResource, '/chemicals/query')
    api.add_resource(UserPIResource, '/users/<int:user_id>/pis')
    api.add_resource(UserResource, '/users')
    api.add_resource(PIResource, '/pis')
    api.add_resource(PIListResource, '/pis/all')  
    api.add_resource(UserListResource, '/users/all')  
    api.add_resource(BuildingResource, '/buildings')
    api.add_resource(RoomResource, '/rooms')
    api.add_resource(SpaceResource, '/spaces')
    api.add_resource(UserPIAssociationResource, '/users/<int:user_id>/pis/<int:pi_id>')
    api.add_resource(ChemicalsByRoom, '/chemicals/room/<int:room_id>')
