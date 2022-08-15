package com.meeting.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cloudroom.cloudroomvideosdk.CloudroomVideoMeeting
import com.example.meetingdemo.R
import com.meeting.example.common.IMmsg
import java.text.SimpleDateFormat

/**
 * Created by zjw on 2021/12/27.
 */
class IMAdapter(val context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var mData = arrayListOf<IMmsg>()
    private val TYPE_MINE = 0
    private val TYPE_OTHERS = 1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == TYPE_MINE) {
            MineViewHolder(LayoutInflater.from(context).inflate(R.layout.item_my, parent, false))
        } else {
            OthersViewHolder(
                LayoutInflater.from(context).inflate(R.layout.item_others, parent, false)
            )
        }
    }

    override fun getItemViewType(position: Int): Int {
        return if (mData[position].fromUserID == CloudroomVideoMeeting.getInstance().myUserID) {
            TYPE_MINE
        } else {
            TYPE_OTHERS
        }
    }

    fun setData(list: List<IMmsg>) {
        mData.clear()
        mData.addAll(list)
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return mData.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (getItemViewType(position) == TYPE_MINE) {
            (holder as MineViewHolder).setData(position)
        } else {
            (holder as OthersViewHolder).setData(position)
        }
    }

    inner class MineViewHolder(itemview: View) : RecyclerView.ViewHolder(itemview) {
        private val tvMsg = itemView.findViewById<TextView>(R.id.tvMsg)
        private val tvTime = itemView.findViewById<TextView>(R.id.tvTime)
        private val vGap = itemView.findViewById<View>(R.id.vGap)

        fun setData(position: Int) {
            if (position == 0) {
                vGap.visibility = View.VISIBLE
            } else {
                vGap.visibility = View.GONE
            }
            val iMmsg = mData[position]
            tvMsg.text = iMmsg.text
            val dateFormat = SimpleDateFormat("HH:mm")
            tvTime.text = dateFormat.format(iMmsg.sendTime)
        }
    }

    inner class OthersViewHolder(itemview: View) : RecyclerView.ViewHolder(itemview) {
        private val tvMsg = itemView.findViewById<TextView>(R.id.tvMsg)
        private val tvTime = itemView.findViewById<TextView>(R.id.tvTime)
        private val tvName = itemView.findViewById<TextView>(R.id.tvName)
        private val vGap = itemView.findViewById<View>(R.id.vGap)
        fun setData(position: Int) {
            if (position == 0) {
                vGap.visibility = View.VISIBLE
            } else {
                vGap.visibility = View.GONE
            }
            val iMmsg = mData[position]
            tvName.text = "${CloudroomVideoMeeting.getInstance().getNickName(iMmsg.fromUserID)}:"
            tvMsg.text = iMmsg.text
            val dateFormat = SimpleDateFormat("HH:mm")
            tvTime.text = dateFormat.format(iMmsg.sendTime)
        }
    }
}