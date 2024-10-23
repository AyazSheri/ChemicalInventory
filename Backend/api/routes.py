from flask import request, jsonify
from flask_restful import Resource
from db_models.models import db, Chemical, User, PI, Building, Room, Space

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
        new_chemical = Chemical(
            name=data['name'],
            cas_number=data['cas_number'],
            room_id=data['room_id'],
            space_id=data.get('space_id'),  # Optional
            amount=data['amount'],
            unit=data['unit'],
            expiration_date=data.get('expiration_date'),
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

# --- Add the new routes to your app ---
def initialize_routes(api):
    api.add_resource(ChemicalListResource, '/chemicals')
    api.add_resource(ChemicalQueryResource, '/chemicals/query')
    api.add_resource(UserPIResource, '/users/<int:user_id>/pis')
    api.add_resource(UserResource, '/users')
    api.add_resource(PIResource, '/pis')
    api.add_resource(BuildingResource, '/buildings')
    api.add_resource(RoomResource, '/rooms')
    api.add_resource(SpaceResource, '/spaces')
    api.add_resource(UserPIAssociationResource, '/users/<int:user_id>/pis/<int:pi_id>')

